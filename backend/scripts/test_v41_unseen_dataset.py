import os
import sys
import datetime
import collections
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image as keras_image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# Ensure UTF-8 output to prevent Windows console encoding problems
try:
    sys.stdout.reconfigure(encoding="utf-8")
except AttributeError:
    pass

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if PROJECT_ROOT not in sys.path:
    sys.path.append(PROJECT_ROOT)
scripts_dir = os.path.join(PROJECT_ROOT, "scripts")
if scripts_dir not in sys.path:
    sys.path.append(scripts_dir)

from load_member2_model_fixed import load_member2_model

REGIONS = [
    "central_highlands",
    "eastern_dry_zone",
    "north_central_dry_zone",
    "northern_dry_zone",
    "northwestern_intermediate",
    "sabaragamuwa_zone",
    "southern_wet_zone",
    "uva_zone",
    "western_wet_zone"
]

ALL_CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf Scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight"
]

FOLDER_TO_DISEASE = {
    "bacterial_leaf_blight": "Bacterial Leaf Blight",
    "brown_spot": "Brown Spot",
    "healthy_rice": "Healthy Rice Leaf",
    "leaf_blast": "Leaf Blast",
    "leaf_scald": "Leaf Scald",
    "narrow_brown_leaf_spot": "Narrow Brown Leaf Spot",
    "rice_hispa": "Rice Hispa",
    "sheath_blight": "Sheath Blight"
}

IMAGE_EXTENSIONS = ('.jpg', '.jpeg', '.png', '.bmp', '.webp')

def detect_active_classes(dataset_path: str) -> list:
    if not os.path.exists(dataset_path):
        return ALL_CLASSES
    active = []
    for d in sorted(os.listdir(dataset_path)):
        d_path = os.path.join(dataset_path, d)
        if os.path.isdir(d_path):
            n = sum(1 for f in os.listdir(d_path) if f.lower().endswith(IMAGE_EXTENSIONS))
            if n > 0:
                name = d
                if name == "Leaf scald":
                    name = "Leaf Scald"
                active.append(name)
    return active if active else ALL_CLASSES

def load_model_safe(model_path: str) -> tf.keras.Model:
    try:
        model = tf.keras.models.load_model(model_path, compile=False)
        return model
    except Exception:
        return load_member2_model(model_path)

def preprocess_image(image_path: str) -> np.ndarray:
    img = keras_image.load_img(image_path, target_size=(224, 224))
    img_array = keras_image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)
    return img_array

def map_folder_name_to_disease(folder_name: str) -> str:
    clean_name = folder_name.strip().lower()
    if clean_name in FOLDER_TO_DISEASE:
        return FOLDER_TO_DISEASE[clean_name]
    formatted = folder_name.replace("_", " ").strip().title()
    if formatted == "Leaf Scald" or formatted == "Leaf scald":
        return "Leaf Scald"
    return formatted

def evaluate_models_on_unseen(models_dir, test_dir, data_dir):
    models = {}
    classes_map = {}

    for region in REGIONS:
        model_path = os.path.join(models_dir, f"{region}_model.keras")
        if not os.path.exists(model_path):
            continue
        model = load_model_safe(model_path)
        dataset_path = os.path.join(data_dir, region)
        active_classes = detect_active_classes(dataset_path)
        models[region] = model
        classes_map[region] = active_classes

    disease_folders = sorted([
        d for d in os.listdir(test_dir)
        if os.path.isdir(os.path.join(test_dir, d))
    ])

    test_records = []
    total_images_found = 0

    for folder in disease_folders:
        folder_path = os.path.join(test_dir, folder)
        true_disease = map_folder_name_to_disease(folder)

        images = sorted([
            f for f in os.listdir(folder_path)
            if f.lower().endswith(IMAGE_EXTENSIONS)
        ])

        if not images:
            continue

        total_images_found += len(images)

        for img_name in images:
            img_path = os.path.join(folder_path, img_name)
            try:
                img_array = preprocess_image(img_path)
            except Exception:
                continue

            for region, model in models.items():
                active_classes = classes_map[region]
                preds = model.predict(img_array, verbose=0)[0]
                pred_idx = int(np.argmax(preds))
                pred_class = active_classes[pred_idx] if pred_idx < len(active_classes) else "Unknown"
                confidence = float(preds[pred_idx])

                is_correct = (pred_class.lower().strip() == true_disease.lower().strip())

                test_records.append({
                    "image": img_name,
                    "region": region,
                    "true_disease": true_disease,
                    "predicted_disease": pred_class,
                    "confidence": confidence,
                    "is_correct": is_correct
                })

    total_tested = len(test_records)
    correct_count = sum(1 for r in test_records if r["is_correct"])
    wrong_count = total_tested - correct_count
    accuracy = correct_count / total_tested if total_tested > 0 else 0.0
    avg_conf = sum(r["confidence"] for r in test_records) / total_tested if total_tested > 0 else 0.0

    healthy_fps = [
        r for r in test_records
        if r["true_disease"].lower().strip() != "healthy rice leaf" and r["predicted_disease"].lower().strip() == "healthy rice leaf"
    ]

    disease_stats = collections.defaultdict(lambda: {"tested": 0, "correct": 0, "conf_sum": 0.0})
    region_stats = collections.defaultdict(lambda: {"tested": 0, "correct": 0, "conf_sum": 0.0})
    confusion_matrix = collections.defaultdict(lambda: collections.defaultdict(int))

    for r in test_records:
        td = r["true_disease"]
        pd = r["predicted_disease"]
        reg = r["region"]
        conf = r["confidence"]

        disease_stats[td]["tested"] += 1
        disease_stats[td]["conf_sum"] += conf
        region_stats[reg]["tested"] += 1
        region_stats[reg]["conf_sum"] += conf

        confusion_matrix[td][pd] += 1

        if r["is_correct"]:
            disease_stats[td]["correct"] += 1
            region_stats[reg]["correct"] += 1

    return {
        "total_images": total_images_found,
        "total_tested": total_tested,
        "correct_count": correct_count,
        "wrong_count": wrong_count,
        "accuracy": accuracy,
        "avg_confidence": avg_conf,
        "healthy_fps": healthy_fps,
        "healthy_fps_count": len(healthy_fps),
        "disease_stats": disease_stats,
        "region_stats": region_stats,
        "confusion_matrix": confusion_matrix,
        "test_records": test_records
    }

def main():
    test_dir = os.path.join(PROJECT_ROOT, "test_images_unseen")
    v4_models_dir = os.path.join(PROJECT_ROOT, "trained_models", "v4")
    v41_models_dir = os.path.join(PROJECT_ROOT, "trained_models", "v41")
    data_dir = os.path.join(PROJECT_ROOT, "data_v2")

    report_path = os.path.join(PROJECT_ROOT, "reports", "v41", "unseen_test_results.md")
    os.makedirs(os.path.dirname(report_path), exist_ok=True)

    print("========================================")
    print("EVALUATING V4 vs V4.1 ON UNSEEN DATASET")
    print("========================================\n")

    print("--- Evaluating V4 Models ---")
    v4_res = evaluate_models_on_unseen(v4_models_dir, test_dir, data_dir)

    print("--- Evaluating V4.1 Models ---")
    v41_res = evaluate_models_on_unseen(v41_models_dir, test_dir, data_dir)

    # Prepare markdown report
    lines = []
    lines.append("# CropGuard V4.1 Unseen Dataset Evaluation & Comparison Report")
    lines.append("")
    lines.append(f"**Generated:** {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("")
    lines.append("## Executive Comparison: V4 vs V4.1")
    lines.append("")
    lines.append("| Metric | V4 Baseline Models | V4.1 Active Learning Models | Improvement / Change |")
    lines.append("| :--- | :---: | :---: | :---: |")
    lines.append(f"| **Overall Accuracy** | {v4_res['accuracy']:.2%} | {v41_res['accuracy']:.2%} | **{v41_res['accuracy'] - v4_res['accuracy']:+.2%}** |")
    lines.append(f"| **Average Confidence** | {v4_res['avg_confidence']:.2%} | {v41_res['avg_confidence']:.2%} | {v41_res['avg_confidence'] - v4_res['avg_confidence']:+.2%} |")
    lines.append(f"| **Healthy False Positives (Lower is better)** | {v4_res['healthy_fps_count']} | **{v41_res['healthy_fps_count']}** | **{v41_res['healthy_fps_count'] - v4_res['healthy_fps_count']:+}** |")
    lines.append(f"| **Total Correct Predictions** | {v4_res['correct_count']} | {v41_res['correct_count']} | {v41_res['correct_count'] - v4_res['correct_count']:+} |")
    lines.append("")

    # Success Criteria check
    target_met = v41_res['healthy_fps_count'] < 40
    status_str = "PASSED (Target < 40 met!)" if target_met else "NEEDS FURTHER TUNING"
    lines.append(f"### Target Verification: Healthy False Positives < 40")
    lines.append(f"- **V4 Baseline**: {v4_res['healthy_fps_count']}")
    lines.append(f"- **V4.1 Result**: {v41_res['healthy_fps_count']}")
    lines.append(f"- **Status**: **{status_str}**")
    lines.append("")

    # Disease Recall & Performance Comparison
    lines.append("## Disease Recall & Accuracy Comparison")
    lines.append("")
    lines.append("| Disease Class | V4 Recall / Accuracy | V4.1 Recall / Accuracy | Recall Improvement |")
    lines.append("| :--- | :---: | :---: | :---: |")

    for d in ALL_CLASSES:
        v4_d = v4_res['disease_stats'].get(d, {"tested": 0, "correct": 0})
        v41_d = v41_res['disease_stats'].get(d, {"tested": 0, "correct": 0})

        v4_acc = v4_d['correct'] / v4_d['tested'] if v4_d['tested'] > 0 else 0.0
        v41_acc = v41_d['correct'] / v41_d['tested'] if v41_d['tested'] > 0 else 0.0
        imp = v41_acc - v4_acc

        lines.append(f"| **{d}** | {v4_acc:.2%} ({v4_d['correct']}/{v4_d['tested']}) | {v41_acc:.2%} ({v41_d['correct']}/{v41_d['tested']}) | **{imp:+.2%}** |")
    lines.append("")

    # Regional Performance Comparison
    lines.append("## Regional Accuracy Comparison")
    lines.append("")
    lines.append("| Region | V4 Accuracy | V4.1 Accuracy | Improvement | V4 Healthy FP | V4.1 Healthy FP |")
    lines.append("| :--- | :---: | :---: | :---: | :---: | :---: |")

    for reg in REGIONS:
        v4_r = v4_res['region_stats'].get(reg, {"tested": 0, "correct": 0})
        v41_r = v41_res['region_stats'].get(reg, {"tested": 0, "correct": 0})

        v4_r_acc = v4_r['correct'] / v4_r['tested'] if v4_r['tested'] > 0 else 0.0
        v41_r_acc = v41_r['correct'] / v41_r['tested'] if v41_r['tested'] > 0 else 0.0

        v4_hfp = sum(1 for r in v4_res['healthy_fps'] if r['region'] == reg)
        v41_hfp = sum(1 for r in v41_res['healthy_fps'] if r['region'] == reg)

        lines.append(f"| `{reg}` | {v4_r_acc:.2%} | {v41_r_acc:.2%} | {v41_r_acc - v4_r_acc:+.2%} | {v4_hfp} | **{v41_hfp}** |")
    lines.append("")

    # V4.1 Confusion Matrix
    lines.append("## V4.1 Confusion Matrix")
    lines.append("")
    lines.append("| True Disease \\ Predicted | " + " | ".join(ALL_CLASSES) + " |")
    lines.append("| :--- | " + " | ".join(["---" for _ in ALL_CLASSES]) + " |")
    for true_d in ALL_CLASSES:
        row_vals = []
        for pred_d in ALL_CLASSES:
            row_vals.append(str(v41_res['confusion_matrix'][true_d][pred_d]))
        lines.append(f"| **{true_d}** | " + " | ".join(row_vals) + " |")
    lines.append("")

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    # Console Summary Output
    print("========================================")
    print("CROPGUARD V4.1 UNSEEN DATASET TEST")
    print("========================================")
    print(f"Total images evaluated: {v41_res['total_tested']}")
    print(f"Correct predictions: {v41_res['correct_count']} (V4 was {v4_res['correct_count']})")
    print(f"Accuracy: {v41_res['accuracy']:.2%} (V4 was {v4_res['accuracy']:.2%})")
    print(f"Average Confidence: {v41_res['avg_confidence']:.2%}")
    print(f"Healthy false positives: {v41_res['healthy_fps_count']} (V4 was {v4_res['healthy_fps_count']})")
    print(f"Target (<40 Healthy FP): {'MET ✅' if target_met else 'NOT MET ❌'}")
    print(f"Report saved to: {report_path}")
    print("========================================\n")

if __name__ == "__main__":
    main()
