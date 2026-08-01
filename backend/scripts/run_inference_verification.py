import os
import sys
import json
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# Ensure UTF-8 output to prevent Windows console encoding problems
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

REGIONS = [
    "central_highlands",
    "uva_zone",
    "eastern_dry_zone",
    "north_central_dry_zone",
    "northern_dry_zone",
    "northwestern_intermediate",
    "sabaragamuwa_zone",
    "southern_wet_zone",
    "western_wet_zone"
]

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def detect_active_classes(dataset_path):
    """
    Scans the regional dataset folder and detects which disease subfolders contain images.
    Returns the sorted list of disease subfolders with at least 1 image.
    This matches the labels mapping used during training.
    """
    if not os.path.exists(dataset_path):
        raise FileNotFoundError(f"Regional dataset directory not found: {dataset_path}")
        
    active_classes = []
    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp')
    
    # Inspect subdirectories
    for d in sorted(os.listdir(dataset_path)):
        d_path = os.path.join(dataset_path, d)
        if os.path.isdir(d_path):
            img_count = sum(
                1 for f in os.listdir(d_path)
                if f.lower().endswith(image_extensions)
            )
            if img_count > 0:
                active_classes.append(d)
                
    if not active_classes:
        raise ValueError(f"No image subfolders containing images found in {dataset_path}")
        
    return active_classes

def main():
    print("============================================================")
    print("RUNNING CROP GUARD INFERENCE VERIFICATION & REPORT GENERATION")
    print("============================================================\n")
    
    inference_details = []
    region_summaries = []
    handover_details = []
    
    all_regions_passed = True
    
    for idx, region in enumerate(REGIONS, 1):
        print(f"[{idx}/{len(REGIONS)}] Verifying region: {region}...")
        
        model_path = os.path.join(PROJECT_ROOT, "automl_models", f"{region}_best_model.keras")
        dataset_path = os.path.join(PROJECT_ROOT, "data", region)
        json_path = os.path.join(PROJECT_ROOT, "automl_results", f"{region}_best_hyperparameters.json")
        
        # 1. Load active classes
        try:
            active_classes = detect_active_classes(dataset_path)
            print(f"  - Active Classes: {', '.join(active_classes)}")
        except Exception as e:
            print(f"  ❌ Error detecting active classes: {e}")
            all_regions_passed = False
            continue
            
        # 2. Load model
        model = None
        if os.path.exists(model_path):
            try:
                model = tf.keras.models.load_model(model_path, compile=False)
                print(f"  - Loaded model (Input: {model.input_shape}, Output: {model.output_shape})")
            except Exception as e:
                print(f"  - Standard load failed: {e}. Trying fallback loader...")
                try:
                    sys.path.append(PROJECT_ROOT)
                    from load_member2_model_fixed import load_member2_model
                    model = load_member2_model(model_path)
                    print("  - Loaded model via fallback loader!")
                except Exception as fe:
                    print(f"  ❌ Model failed to load: {fe}")
                    all_regions_passed = False
                    continue
        else:
            print(f"  ❌ Model file missing at: {model_path}")
            all_regions_passed = False
            continue
            
        # Verify output dimension matches
        num_classes = len(active_classes)
        output_dim = model.output_shape[-1]
        if output_dim != num_classes:
            print(f"  ⚠️ Warning: Model output shape ({output_dim}) does not match active class count ({num_classes})")
            
        # 3. Load Hyperparameters and baseline / automl accuracy
        baseline_acc = "N/A"
        automl_acc = "N/A"
        best_hps = {}
        if os.path.exists(json_path):
            try:
                with open(json_path, "r", encoding="utf-8") as f:
                    hp_data = json.load(f)
                baseline_acc = f"{hp_data.get('baseline_accuracy', 0.0):.4f}%"
                automl_acc = f"{hp_data.get('automl_accuracy', 0.0):.4f}%"
                best_hps = {
                    "dense_units": hp_data.get("dense_units"),
                    "dropout": hp_data.get("dropout"),
                    "learning_rate": hp_data.get("learning_rate"),
                    "optimizer": hp_data.get("optimizer")
                }
            except Exception as e:
                print(f"  ⚠️ Error loading hyperparameters JSON: {e}")
                
        # 4. Perform Inference Verification
        total_tested = 0
        correct_predictions = 0
        confidences = []
        
        region_images_log = []
        
        image_extensions = ('.jpg', '.jpeg', '.png', '.bmp')
        for cls in active_classes:
            class_dir = os.path.join(dataset_path, cls)
            all_images = sorted([
                f for f in os.listdir(class_dir)
                if f.lower().endswith(image_extensions)
            ])
            
            # Select 3 sample images
            test_images = all_images[:3]
            for img_name in test_images:
                img_path = os.path.join(class_dir, img_name)
                total_tested += 1
                
                try:
                    # Preprocess
                    img = image.load_img(img_path, target_size=(224, 224))
                    img_array = image.img_to_array(img)
                    img_array = np.expand_dims(img_array, axis=0)
                    img_array = preprocess_input(img_array)
                    
                    # Predict
                    preds = model.predict(img_array, verbose=0)[0]
                    pred_idx = int(np.argmax(preds))
                    pred_cls = active_classes[pred_idx] if pred_idx < len(active_classes) else "Unknown"
                    confidence = float(preds[pred_idx])
                    confidences.append(confidence)
                    
                    is_correct = (pred_cls == cls)
                    if is_correct:
                        correct_predictions += 1
                        status = "PASS"
                    else:
                        status = "FAIL"
                        
                    region_images_log.append({
                        "image_name": img_name,
                        "actual": cls,
                        "predicted": pred_cls,
                        "confidence": confidence,
                        "status": status
                    })
                except Exception as e:
                    print(f"    ❌ Error running inference on {img_name}: {e}")
                    region_images_log.append({
                        "image_name": img_name,
                        "actual": cls,
                        "predicted": "ERROR",
                        "confidence": 0.0,
                        "status": "FAIL"
                    })
                    
        # Calculate summary metrics
        accuracy = (correct_predictions / total_tested) * 100.0 if total_tested > 0 else 0.0
        avg_confidence = np.mean(confidences) if confidences else 0.0
        
        # Mark as PASS if accuracy is >= 80% (acceptable functional verification)
        region_status = "PASS" if (accuracy >= 80.0 and total_tested > 0) else "FAIL"
        
        print(f"  - Results: Tested={total_tested}, Correct={correct_predictions}, Accuracy={accuracy:.2f}%, Avg Conf={avg_confidence:.2%}, Status={region_status}")
        
        region_summaries.append({
            "region": region,
            "active_classes": active_classes,
            "images_tested": total_tested,
            "correct": correct_predictions,
            "accuracy": f"{accuracy:.2f}%",
            "avg_confidence": f"{avg_confidence:.2%}",
            "status": region_status
        })
        
        inference_details.append({
            "region": region,
            "images": region_images_log
        })
        
        handover_details.append({
            "region": region,
            "filename": f"{region}_best_model.keras",
            "active_classes": active_classes,
            "val_accuracy": baseline_acc,
            "automl_accuracy": automl_acc,
            "hps": best_hps
        })
        
        if region_status == "FAIL":
            all_regions_passed = False
            
    # 5. Generate final_verification_report.md
    report_content = []
    report_content.append("# CropGuard AutoML Regional Model Final Verification Report")
    report_content.append("")
    report_content.append("This report lists the results of running inference verification on the finalized, optimized regional AutoML models. For each active class in each region, 3 sample images were selected, preprocessed, and classified by the corresponding AutoML model to verify correct functionality and lack of corruption.")
    report_content.append("")
    report_content.append("## Executive Summary")
    report_content.append("")
    report_content.append("| Region | Active Classes Count | Images Tested | Correct Predictions | Inference Accuracy | Average Confidence | Overall Status |")
    report_content.append("| :--- | :---: | :---: | :---: | :---: | :---: | :---: |")
    for summary in region_summaries:
        status_emoji = "✅ PASS" if summary["status"] == "PASS" else "❌ FAIL"
        report_content.append(f"| **{summary['region'].replace('_', ' ').title()}** | {len(summary['active_classes'])} | {summary['images_tested']} | {summary['correct']} | {summary['accuracy']} | {summary['avg_confidence']} | **{status_emoji}** |")
    report_content.append("")
    report_content.append("## Detailed Prediction Records")
    report_content.append("")
    
    for details in inference_details:
        r_name = details["region"].replace('_', ' ').title()
        report_content.append(f"### Region: `{details['region']}` ({r_name})")
        report_content.append("")
        report_content.append("| Image File | Actual Class | Predicted Class | Confidence | Status |")
        report_content.append("| :--- | :--- | :--- | :---: | :---: |")
        for img in details["images"]:
            pass_emoji = "✅ PASS" if img["status"] == "PASS" else "❌ FAIL"
            report_content.append(f"| `{img['image_name']}` | {img['actual']} | {img['predicted']} | {img['confidence']:.2%} | {pass_emoji} |")
        report_content.append("")
        
    report_file_path = os.path.join(PROJECT_ROOT, "final_verification_report.md")
    with open(report_file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report_content))
    print(f"Generated {report_file_path}")
    
    # 6. Generate handover_to_member1.md
    handover_content = []
    handover_content.append("# CropGuard AutoML Regional Models - Handover Documentation")
    handover_content.append("")
    handover_content.append("This document provides detailed metadata and requirements for each of the optimized regional AutoML models to facilitate transition to **Member 1** for TinyML compilation and hardware deployment (Edge AI Active Learning).")
    handover_content.append("")
    handover_content.append("## Global Model Settings (Common to All Regions)")
    handover_content.append("- **Base Architecture**: MobileNetV2")
    handover_content.append("- **Input Tensor Shape**: `224×224×3` (Width: 224, Height: 224, Channels: RGB)")
    handover_content.append("- **Required Preprocessing**: Pixel normalization using MobileNetV2 `preprocess_input` (transforms pixel values from standard `[0, 255]` range to `[-1, 1]`)")
    handover_content.append("- **Format**: Keras Model Bundle (`.keras` format containing architecture, weights, and configuration)")
    handover_content.append("")
    handover_content.append("## Regional Models Directory & Specifications")
    for details in handover_details:
        r_name = details["region"].replace('_', ' ').title()
        handover_content.append(f"### {r_name}")
        handover_content.append(f"- **Model Filename**: `automl_models/{details['filename']}`")
        handover_content.append(f"- **Active Classes ({len(details['active_classes'])}):** " + ", ".join([f"`{cls}`" for cls in details["active_classes"]]))
        handover_content.append(f"- **Baseline Validation Accuracy**: `{details['val_accuracy']}`")
        handover_content.append(f"- **Optimized AutoML Validation Accuracy**: `{details['automl_accuracy']}`")
        handover_content.append("- **Best Discovered Hyperparameters (AutoML):**")
        for k, v in details["hps"].items():
            handover_content.append(f"  - *{k}*: `{v}`")
        handover_content.append("")
        
    handover_file_path = os.path.join(PROJECT_ROOT, "handover_to_member1.md")
    with open(handover_file_path, "w", encoding="utf-8") as f:
        f.write("\n".join(handover_content))
    print(f"Generated {handover_file_path}")
    
    if all_regions_passed:
        print("\n🎉 ALL INFERENCE VERIFICATIONS COMPLETED SUCCESSFULLY!")
        sys.exit(0)
    else:
        print("\n❌ SOME INFERENCE VERIFICATIONS FAILED!")
        sys.exit(1)

if __name__ == "__main__":
    main()
