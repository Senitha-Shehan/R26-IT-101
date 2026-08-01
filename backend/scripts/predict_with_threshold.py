import os
import sys
import argparse
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image as keras_image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# Ensure UTF-8 output to prevent Windows console encoding problems
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
LOW_CONFIDENCE_LABEL = "Low Confidence - Cannot Determine"
IMAGE_EXTENSIONS = ('.jpg', '.jpeg', '.png', '.bmp', '.webp')

# ---------------------------------------------------------------------------
# Helpers (mirrors detect_active_classes from test_regional_model.py exactly)
# ---------------------------------------------------------------------------

def detect_active_classes(dataset_path):
    """
    Scans the regional dataset folder and detects which disease subfolders
    contain images. Returns the sorted list of subfolders with >= 1 image.
    This MUST match the ordering used during training (sorted alphabetically).
    """
    if not os.path.exists(dataset_path):
        raise FileNotFoundError(
            f"Regional dataset directory not found: {dataset_path}"
        )

    active_classes = []
    for d in sorted(os.listdir(dataset_path)):
        d_path = os.path.join(dataset_path, d)
        if os.path.isdir(d_path):
            img_count = sum(
                1 for f in os.listdir(d_path)
                if f.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp'))
            )
            if img_count > 0:
                active_classes.append(d)

    if not active_classes:
        raise ValueError(
            f"No image subfolders containing images found in {dataset_path}"
        )

    return active_classes


def load_regional_model(model_path):
    """
    Loads a regional Keras model.  Falls back to the custom loader if the
    standard keras.models.load_model raises an exception (batch-norm fix).
    """
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model file not found at: {model_path}")

    try:
        model = tf.keras.models.load_model(model_path, compile=False)
        return model
    except Exception as e:
        print(f"  Standard load failed ({e}).  Trying fallback loader...")
        try:
            project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            if project_root not in sys.path:
                sys.path.append(project_root)
            from scripts.load_member2_model_fixed import load_member2_model
            return load_member2_model(model_path)
        except Exception as fe:
            raise RuntimeError(f"Both loaders failed.\n  Standard: {e}\n  Fallback: {fe}")


# ---------------------------------------------------------------------------
# Core prediction function
# ---------------------------------------------------------------------------

def predict_with_threshold(
    region_name,
    model_path,
    image_path,
    dataset_dir="data",
    threshold=0.70,
    verbose=True,
):
    """
    Runs a single-image inference with a confidence threshold safety gate.

    Parameters
    ----------
    region_name  : str   – Agricultural region key (e.g. 'southern_wet_zone')
    model_path   : str   – Path to the .keras model file
    image_path   : str   – Path to the input image
    dataset_dir  : str   – Root data directory (contains region sub-folders)
    threshold    : float – Minimum softmax confidence to accept a prediction.
                           Predictions below this are returned as
                           LOW_CONFIDENCE_LABEL.
    verbose      : bool  – Print detailed report to stdout

    Returns
    -------
    dict with keys:
        predicted_class  : str   – Class name or LOW_CONFIDENCE_LABEL
        confidence       : float – Max softmax probability
        below_threshold  : bool  – True when prediction was suppressed
        all_probs        : list of (class_name, probability) tuples, sorted desc
    """

    # ------------------------------------------------------------------
    # 1. Resolve dataset path and detect active class labels
    # ------------------------------------------------------------------
    dataset_path = os.path.join(dataset_dir, region_name)
    active_classes = detect_active_classes(dataset_path)
    num_classes = len(active_classes)

    # ------------------------------------------------------------------
    # 2. Load model
    # ------------------------------------------------------------------
    model = load_regional_model(model_path)

    output_dim = model.output_shape[-1]
    if output_dim != num_classes:
        print(
            f"  WARNING: Model output dimension ({output_dim}) does not match "
            f"detected class count ({num_classes}).  Class mapping may be wrong."
        )

    # ------------------------------------------------------------------
    # 3. Preprocess image  (identical to test_regional_model.py)
    # ------------------------------------------------------------------
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Test image not found at: {image_path}")

    img = keras_image.load_img(image_path, target_size=(224, 224))
    img_array = keras_image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)          # -> [-1, 1] range

    # ------------------------------------------------------------------
    # 4. Run inference
    # ------------------------------------------------------------------
    raw_preds = model.predict(img_array, verbose=0)[0]   # shape: (num_classes,)
    pred_idx  = int(np.argmax(raw_preds))
    confidence = float(raw_preds[pred_idx])

    # Build sorted probability list (descending)
    all_probs = sorted(
        zip(active_classes, raw_preds.tolist()),
        key=lambda x: x[1],
        reverse=True
    )

    # ------------------------------------------------------------------
    # 5. Apply threshold gate
    # ------------------------------------------------------------------
    below_threshold = confidence < threshold
    predicted_class = LOW_CONFIDENCE_LABEL if below_threshold else active_classes[pred_idx]

    # ------------------------------------------------------------------
    # 6. Verbose console report
    # ------------------------------------------------------------------
    if verbose:
        sep = "=" * 64
        thin = "-" * 64
        print(f"\n{sep}")
        print(f"  CROPGUARD — REGIONAL PREDICTION (with threshold guard)")
        print(f"{sep}")
        print(f"  Region      : {region_name}")
        print(f"  Model       : {os.path.basename(model_path)}")
        print(f"  Image       : {os.path.basename(image_path)}")
        print(f"  Classes     : {num_classes}  ({', '.join(active_classes)})")
        print(f"  Threshold   : {threshold:.0%}")
        print(f"{thin}")
        print(f"  All class probabilities:")
        for cls, prob in all_probs:
            bar = "█" * int(prob * 30)
            marker = "  <-- TOP" if cls == active_classes[pred_idx] else ""
            print(f"    {cls:<30}  {prob:>6.2%}  {bar}{marker}")
        print(f"{thin}")

        if below_threshold:
            print(f"  RAW top prediction  : {active_classes[pred_idx]}  ({confidence:.2%})")
            print(f"  THRESHOLD CHECK     : {confidence:.2%} < {threshold:.0%} — FAILED")
            print(f"")
            print(f"  ⚠️  RESULT  : {LOW_CONFIDENCE_LABEL}")
        else:
            print(f"  THRESHOLD CHECK     : {confidence:.2%} >= {threshold:.0%} — PASSED")
            print(f"")
            print(f"  ✅  RESULT  : {predicted_class}  ({confidence:.2%} confidence)")

        print(f"{sep}\n")

    return {
        "predicted_class": predicted_class,
        "confidence":      confidence,
        "below_threshold": below_threshold,
        "all_probs":       all_probs,
    }


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description=(
            "CropGuard — Regional Model Inference with Confidence Threshold.\n"
            "Wraps the standard regional model inference with a safety gate:\n"
            "predictions below --threshold are returned as\n"
            f'"{LOW_CONFIDENCE_LABEL}" instead of a forced class.'
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "--region",
        type=str,
        required=True,
        help=(
            "Name of the agricultural region "
            "(e.g. southern_wet_zone, central_highlands)"
        ),
    )
    parser.add_argument(
        "--model-path",
        type=str,
        required=True,
        help="Path to the trained regional .keras model file",
    )
    parser.add_argument(
        "--image-path",
        type=str,
        required=True,
        help="Path to the input leaf image to classify",
    )
    parser.add_argument(
        "--dataset-dir",
        type=str,
        default="data",
        help="Root data directory that contains the regional sub-folders (default: data)",
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=0.70,
        help=(
            "Minimum softmax confidence required to accept a prediction. "
            "Predictions below this value are output as "
            f'"{LOW_CONFIDENCE_LABEL}". '
            "Range: 0.0–1.0  (default: 0.70)"
        ),
    )

    args = parser.parse_args()

    # Validate threshold range
    if not (0.0 < args.threshold <= 1.0):
        parser.error("--threshold must be in the range (0.0, 1.0]")

    result = predict_with_threshold(
        region_name=args.region,
        model_path=args.model_path,
        image_path=args.image_path,
        dataset_dir=args.dataset_dir,
        threshold=args.threshold,
        verbose=True,
    )

    # Exit with code 2 if prediction was suppressed (useful for scripting)
    sys.exit(2 if result["below_threshold"] else 0)


if __name__ == "__main__":
    main()
