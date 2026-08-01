import os
import sys
import argparse
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# Ensure UTF-8 output to prevent Windows console encoding problems
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

GLOBAL_CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf Scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight"
]

def detect_active_classes(dataset_path):
    """
    Scans the regional dataset folder and detects which disease subfolders contain images.
    Returns set of disease names available in the region.
    """
    if not os.path.exists(dataset_path):
        fallback_path = dataset_path.replace("data_v2", "data") if "data_v2" in dataset_path else dataset_path.replace("data", "data_v2")
        if os.path.exists(fallback_path):
            dataset_path = fallback_path
        else:
            return set(GLOBAL_CLASSES)
        
    active_classes = set()
    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp', '.webp')
    
    if os.path.exists(dataset_path):
        for d in os.listdir(dataset_path):
            d_path = os.path.join(dataset_path, d)
            if os.path.isdir(d_path):
                img_count = sum(
                    1 for f in os.listdir(d_path)
                    if f.lower().endswith(image_extensions)
                )
                if img_count > 0:
                    name = d
                    if name == "Leaf scald":
                        name = "Leaf Scald"
                    active_classes.add(name)
                    
    return active_classes if active_classes else set(GLOBAL_CLASSES)

def resolve_path(path_value, fallback_relative_parts=()):
    """
    Resolve a user-supplied path against the current working directory and the project root.
    If the path does not exist, try a project-root-relative fallback built from fallback_relative_parts.
    """
    if not path_value:
        return path_value

    candidates = [path_value]
    if not os.path.isabs(path_value):
        candidates.append(os.path.join(PROJECT_ROOT, path_value))

    if fallback_relative_parts:
        candidates.append(os.path.join(PROJECT_ROOT, *fallback_relative_parts))

    for candidate in candidates:
        normalized = os.path.normpath(candidate)
        if os.path.exists(normalized):
            return normalized

    return os.path.normpath(path_value)

def test_inference(region_name, model_path=None, image_path=None, dataset_dir="data_v2"):
    """
    Loads V4/V4.1 regional model, checks regional disease availability, preprocesses input image,
    runs prediction mapping directly to the global 8 CropGuard classes, and displays output metrics.
    """
    if not model_path:
        model_path = os.path.join("trained_models", "v4", f"{region_name}_model.keras")

    model_path = resolve_path(model_path)
    dataset_dir = resolve_path(dataset_dir)
    image_path = resolve_path(
        image_path,
        fallback_relative_parts=("test_images", os.path.basename(image_path)) if image_path else ()
    )

    print(f"\n============================================================")
    print(f"CROPGUARD REGIONAL MODEL INFERENCE TEST")
    print(f"============================================================")
    print(f"Region: {region_name}")
    print(f"Model Path: {model_path}")
    print(f"Image Path: {image_path}")
    print(f"------------------------------------------------------------")
    
    # 1. Resolve regional active classes for regional availability warnings
    dataset_path = os.path.join(dataset_dir, region_name)
    regional_active = detect_active_classes(dataset_path)
    
    print(f"Global CropGuard Classes ({len(GLOBAL_CLASSES)}):")
    for idx, cls in enumerate(GLOBAL_CLASSES):
        status = "Available in region" if cls in regional_active else "Not in regional dataset"
        print(f"  [{idx}] {cls} ({status})")
        
    # 2. Load the regional model
    if not os.path.exists(model_path):
        print(f"❌ Model file not found at: {model_path}")
        sys.exit(1)
        
    print(f"\nLoading regional model...")

    print("ABS MODEL PATH:")
    print(os.path.abspath(model_path))
    print("MODEL SIZE:")
    print(os.path.getsize(model_path))
    try:
        model = tf.keras.models.load_model(model_path, compile=False)
        print("✅ Model loaded successfully!")
        print("MODEL DEBUG")
        print("Input:", model.input_shape)
        print("Output:", model.output_shape)
        print("Layers:", len(model.layers))
        print("Last layers:")

        for l in model.layers[-5:]:
            print(l.name)
    except Exception as e:
        print(f"❌ Standard keras load failed: {e}")
        # Try custom fallback loader
        try:
            print("Attempting fallback loader...")
            project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            if project_root not in sys.path:
                sys.path.append(project_root)
            scripts_dir = os.path.join(project_root, "scripts")
            if scripts_dir not in sys.path:
                sys.path.append(scripts_dir)
            from load_member2_model_fixed import load_member2_model
            model = load_member2_model(model_path)
            print("✅ Model loaded successfully via fallback loader!")
        except Exception as fallback_err:
            print(f"❌ Fallback loading also failed: {fallback_err}")
            sys.exit(1)
            
    # 3. Verify output dimension matches global classes (8)
    output_dim = model.output_shape[-1]
    if output_dim != len(GLOBAL_CLASSES):
        print(f"⚠️ Warning: Model output dimension ({output_dim}) does not match global class count ({len(GLOBAL_CLASSES)}).")
        
    # 4. Load and preprocess image
    if not os.path.exists(image_path):
        print(f"❌ Test image not found at: {image_path}")
        sys.exit(1)
        
    img = image.load_img(image_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)
    
    # 5. Inference prediction - map output index directly to GLOBAL_CLASSES
    predictions = model.predict(img_array, verbose=0)[0]
    print("RAW SCRIPT OUTPUT:")
    print(predictions)
    predicted_idx = int(np.argmax(predictions))
    predicted_class = GLOBAL_CLASSES[predicted_idx] if predicted_idx < len(GLOBAL_CLASSES) else "Unknown"
    confidence = float(predictions[predicted_idx])
    
    # 6. Check regional availability warning
    is_available_in_region = predicted_class in regional_active
    if not is_available_in_region:
        print(f"\n⚠️ WARNING: Predicted disease '{predicted_class}' is NOT available/present in region '{region_name}'.")
        
    # 7. Display results
    print(f"\nResults:")
    print(f"  Region:                {region_name}")
    print(f"  Predicted class:       {predicted_class}")
    print(f"  Confidence percentage: {confidence:.2%}")
    if not is_available_in_region:
        print(f"  Regional Warning:      ⚠️ '{predicted_class}' is not typical for {region_name}")
    
    print(f"\nTop 3 predictions:")
    sorted_predictions = sorted(
        zip(GLOBAL_CLASSES, predictions),
        key=lambda x: x[1],
        reverse=True
    )
    for cls, prob in sorted_predictions[:3]:
        avail_str = "" if cls in regional_active else " ⚠️ (Not in region)"
        print(f"  - {cls}: {prob:.2%}{avail_str}")
    print(f"============================================================\n")
    return predicted_class, confidence

def main():
    parser = argparse.ArgumentParser(description="Inference testing for CropGuard V4 regional models")
    parser.add_argument("--region", type=str, required=True, help="Name of agricultural region")
    parser.add_argument("--model-path", type=str, default=None, help="Path to trained V4/V4.1 Keras model")
    parser.add_argument("--image-path", type=str, required=True, help="Path to input test image")
    parser.add_argument("--dataset-dir", type=str, default="data_v2", help="Directory containing regional folders")
    
    args = parser.parse_args()
    model_path = args.model_path if args.model_path else os.path.join("trained_models", "v4", f"{args.region}_model.keras")
    
    test_inference(
        region_name=args.region,
        model_path=model_path,
        image_path=args.image_path,
        dataset_dir=args.dataset_dir
    )

if __name__ == "__main__":
    main()


