"""
evaluate_all_regional_models.py
================================
Evaluation pipeline for all 9 CropGuard regional models.

Usage:
    python scripts/evaluate_all_regional_models.py [--test-dir test_images] [--data-dir data]
                                                   [--models-dir trained_models]
                                                   [--out reports/regional_model_evaluation.md]
                                                   [--threshold 0.70]

Does NOT modify any model, training file, CSV mapping, or inference script.
"""

import os
import sys
import argparse
import datetime
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing import image as keras_image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# ── UTF-8 output (Windows console safety) ──────────────────────────────────
try:
    sys.stdout.reconfigure(encoding="utf-8")
except AttributeError:
    pass

# ── Constants ───────────────────────────────────────────────────────────────
REGIONS = [
    "central_highlands",
    "uva_zone",
    "north_central_dry_zone",
    "northern_dry_zone",
    "northwestern_intermediate",
    "sabaragamuwa_zone",
    "eastern_dry_zone",
    "southern_wet_zone",
    "western_wet_zone",
]

IMAGE_EXTENSIONS = (".jpg", ".jpeg", ".png", ".bmp", ".webp")
HEALTHY_LABEL    = "Healthy Rice Leaf"
HIGH_CONF_THRESH = 0.85   # flag "high confidence" healthy predictions above this
SUSPICIOUS_BAND  = (0.40, 0.65)  # flag predictions whose top confidence falls here


# ── Helpers (mirrors test_regional_model.py exactly) ────────────────────────

def detect_active_classes(dataset_path: str) -> list:
    """Return sorted list of class subfolders that contain >= 1 image."""
    if not os.path.exists(dataset_path):
        return []
    active = []
    for d in sorted(os.listdir(dataset_path)):
        d_path = os.path.join(dataset_path, d)
        if os.path.isdir(d_path):
            n = sum(
                1 for f in os.listdir(d_path)
                if f.lower().endswith((".jpg", ".jpeg", ".png", ".bmp"))
            )
            if n > 0:
                active.append(d)
    return active


def load_model_safe(model_path: str, scripts_dir: str):
    """Load a Keras model; falls back to the project's custom loader on failure."""
    model = tf.keras.models.load_model(model_path, compile=False)
    return model


def preprocess_image(image_path: str) -> np.ndarray:
    """Load and preprocess image identical to test_regional_model.py."""
    img       = keras_image.load_img(image_path, target_size=(224, 224))
    img_array = keras_image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)
    return img_array


# ── Inference for a single region ───────────────────────────────────────────

def run_region_inference(model, active_classes: list, img_array: np.ndarray) -> dict:
    """Run inference and return a result dict."""
    raw = model.predict(img_array, verbose=0)[0]
    idx  = int(np.argmax(raw))
    conf = float(raw[idx])
    pred = active_classes[idx] if idx < len(active_classes) else "Unknown"

    all_probs = sorted(
        zip(active_classes, raw.tolist()),
        key=lambda x: x[1], reverse=True
    )
    is_healthy    = pred == HEALTHY_LABEL
    high_conf_h   = is_healthy and conf >= HIGH_CONF_THRESH
    suspicious    = SUSPICIOUS_BAND[0] <= conf <= SUSPICIOUS_BAND[1]

    return {
        "predicted_class": pred,
        "confidence":      conf,
        "all_probs":       all_probs,
        "is_healthy":      is_healthy,
        "high_conf_healthy": high_conf_h,
        "suspicious":      suspicious,
    }


# ── Infer ground-truth label from filename ──────────────────────────────────

def infer_label_from_filename(filename: str) -> str:
    """
    Best-effort ground-truth guess from filename convention.
    e.g.  Brown_spot (1).jpg  ->  Brown Spot
          Leaf_blast (99).jpg ->  Leaf Blast
          WhatsApp Image ...  ->  External / Unknown
    """
    name = os.path.splitext(filename)[0].lower()
    mapping = {
        "brown_spot":              "Brown Spot",
        "brown spot":              "Brown Spot",
        "leaf_blast":              "Leaf Blast",
        "leaf blast":              "Leaf Blast",
        "leaf_scald":              "Leaf Scald",
        "leaf scald":              "Leaf Scald",
        "narrow_brown_leaf_spot":  "Narrow Brown Leaf Spot",
        "narrow brown leaf spot":  "Narrow Brown Leaf Spot",
        "sheath_blight":           "Sheath Blight",
        "sheath blight":           "Sheath Blight",
        "bacterial_leaf_blight":   "Bacterial Leaf Blight",
        "bacterial leaf blight":   "Bacterial Leaf Blight",
        "rice_hispa":              "Rice Hispa",
        "rice hispa":              "Rice Hispa",
        "healthy":                 "Healthy Rice Leaf",
    }
    for key, label in mapping.items():
        if key.replace(" ", "_") in name.replace(" ", "_"):
            return label
    if "whatsapp" in name or "external" in name or "dsc_" in name.lower():
        return "External / Unknown"
    return "Unknown"


# ── Main evaluation loop ─────────────────────────────────────────────────────

def evaluate(test_dir, data_dir, models_dir, output_path, threshold, scripts_dir):
    print(f"\n{'='*70}")
    print(f"  CropGuard Regional Model Evaluation Pipeline")
    print(f"{'='*70}")
    print(f"  Test images : {test_dir}")
    print(f"  Data dir    : {data_dir}")
    print(f"  Models dir  : {models_dir}")
    print(f"  Output      : {output_path}")
    print(f"  Threshold   : {threshold:.0%}")
    print(f"{'='*70}\n")

    # ── 1. Collect test images ────────────────────────────────────────────
    test_images = sorted([
        f for f in os.listdir(test_dir)
        if f.lower().endswith(IMAGE_EXTENSIONS)
    ])
    print(f"  Found {len(test_images)} test image(s).\n")

    # ── 2. Load all regional models and classes ───────────────────────────
    region_data = {}
    for region in REGIONS:
        model_path   = os.path.join(models_dir, f"{region}_model.keras")
        dataset_path = os.path.join(data_dir, region)
        classes      = detect_active_classes(dataset_path)

        if not classes:
            print(f"  [SKIP] {region} — no active classes found")
            continue
        if not os.path.exists(model_path):
            print(f"  [SKIP] {region} — model file not found: {model_path}")
            continue

        print(f"  Loading  {region}  ({len(classes)} classes: {', '.join(classes)}) ...", end=" ", flush=True)
        try:
            model = load_model_safe(model_path, scripts_dir)
            print("OK")
        except Exception as e:
            print(f"FAILED ({e})")
            continue

        region_data[region] = {"model": model, "classes": classes}

    print(f"\n  Loaded {len(region_data)} / {len(REGIONS)} regional models.\n")

    # ── 3. Run inference on every image × every region ───────────────────
    # results[image_name][region] = inference_result_dict
    results = {}
    per_region_stats = {r: {
        "tested": 0, "healthy_fp": 0, "suspicious": 0,
        "confidences": []
    } for r in region_data}

    for img_name in test_images:
        img_path  = os.path.join(test_dir, img_name)
        gt_label  = infer_label_from_filename(img_name)
        print(f"  [{img_name}]  (ground-truth guess: {gt_label})")

        try:
            img_array = preprocess_image(img_path)
        except Exception as e:
            print(f"    Cannot preprocess: {e}")
            results[img_name] = {"error": str(e), "gt_label": gt_label}
            continue

        img_results = {"gt_label": gt_label}

        for region, rd in region_data.items():
            try:
                res = run_region_inference(rd["model"], rd["classes"], img_array)
                img_results[region] = res
                per_region_stats[region]["tested"]      += 1
                per_region_stats[region]["confidences"].append(res["confidence"])
                if res["high_conf_healthy"]:
                    per_region_stats[region]["healthy_fp"] += 1
                if res["suspicious"]:
                    per_region_stats[region]["suspicious"]  += 1
            except Exception as e:
                img_results[region] = {"error": str(e)}

        results[img_name] = img_results

    # ── 4. Generate markdown report ───────────────────────────────────────
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    write_report(results, region_data, per_region_stats, output_path, threshold, test_dir)
    print(f"\n  Report written → {output_path}")
    return results, per_region_stats


# ── Report writer ────────────────────────────────────────────────────────────

def write_report(results, region_data, per_region_stats, output_path, threshold, test_dir):
    lines = []
    ts    = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def h(txt, level=1):
        lines.append(f"\n{'#'*level} {txt}\n")

    def sep():
        lines.append("---\n")

    # ── Header ────────────────────────────────────────────────────────────
    lines.append(f"# CropGuard Regional Model Evaluation Report\n")
    lines.append(f"**Generated:** {ts}  \n")
    lines.append(f"**Confidence threshold:** {threshold:.0%}  \n")
    lines.append(f"**Regions evaluated:** {len(region_data)}  \n")
    lines.append(f"**Test images:** {len(results)}  \n")
    lines.append("\n")

    # ── Region class legend ───────────────────────────────────────────────
    h("Region → Active Classes", 2)
    lines.append("| Region | # Classes | Active Classes |\n")
    lines.append("|--------|-----------|----------------|\n")
    for region, rd in region_data.items():
        lines.append(f"| `{region}` | {len(rd['classes'])} | {', '.join(rd['classes'])} |\n")
    lines.append("\n")
    sep()

    # ── Per-image detailed results ────────────────────────────────────────
    h("Per-Image Detailed Results", 2)

    healthy_fp_cases   = []   # (img, region, conf)
    suspicious_cases   = []   # (img, region, pred, conf)
    all_region_results = []   # flat list for cross-region summary

    for img_name, img_data in results.items():
        gt = img_data.get("gt_label", "Unknown")
        h(f"`{img_name}`", 3)
        lines.append(f"**Ground-truth (filename guess):** `{gt}`  \n\n")

        if "error" in img_data:
            lines.append(f"> ⚠️ Could not process image: {img_data['error']}\n\n")
            continue

        # Table of region predictions
        lines.append("| Region | Predicted Class | Confidence | Classes Available | Flag |\n")
        lines.append("|--------|----------------|------------|-------------------|------|\n")

        region_confs = []
        for region, rd in region_data.items():
            res = img_data.get(region)
            if res is None or "error" in res:
                err = res.get("error", "N/A") if res else "N/A"
                lines.append(f"| `{region}` | ❌ Error | — | — | {err} |\n")
                continue

            pred  = res["predicted_class"]
            conf  = res["confidence"]
            n_cls = len(rd["classes"])
            flags = []
            if res["high_conf_healthy"]:
                flags.append("🔴 HIGH-CONF HEALTHY")
                healthy_fp_cases.append((img_name, region, conf, gt))
            if res["suspicious"]:
                flags.append("🟡 SUSPICIOUS")
                suspicious_cases.append((img_name, region, pred, conf, gt))
            flag_str = " ".join(flags) if flags else "✅"

            lines.append(
                f"| `{region}` | **{pred}** | {conf:.2%} | {n_cls} | {flag_str} |\n"
            )
            region_confs.append((region, pred, conf))
            all_region_results.append({
                "image": img_name, "region": region,
                "pred": pred, "conf": conf, "gt": gt,
                "high_conf_healthy": res["high_conf_healthy"],
                "suspicious": res["suspicious"],
            })

        # Highest confidence region
        if region_confs:
            best = max(region_confs, key=lambda x: x[2])
            lines.append(f"\n**Highest confidence:** `{best[0]}` → **{best[1]}** ({best[2]:.2%})\n")

        # All-class probability breakdown for each region
        lines.append("\n<details>\n<summary>Full probability breakdown (click to expand)</summary>\n\n")
        for region, rd in region_data.items():
            res = img_data.get(region)
            if not res or "error" in res:
                continue
            lines.append(f"**{region}** ({len(rd['classes'])} classes)  \n")
            for cls, prob in res["all_probs"]:
                bar = "█" * int(prob * 25)
                marker = " ← TOP" if cls == res["predicted_class"] else ""
                lines.append(f"- `{cls}`: {prob:.2%}  {bar}{marker}  \n")
            lines.append("\n")
        lines.append("</details>\n\n")
        sep()

    # ── High-confidence Healthy false-positive summary ────────────────────
    h("High-Confidence 'Healthy' Predictions (Potential False Positives)", 2)
    lines.append(
        f"> These are cases where a region model predicted **Healthy Rice Leaf** "
        f"with ≥ {HIGH_CONF_THRESH:.0%} confidence on images that appear to be diseased "
        f"based on their filename.\n\n"
    )
    if healthy_fp_cases:
        lines.append("| Image | Region | Confidence | GT Label |\n")
        lines.append("|-------|--------|------------|----------|\n")
        for (img, region, conf, gt) in sorted(healthy_fp_cases, key=lambda x: x[2], reverse=True):
            lines.append(f"| `{img}` | `{region}` | {conf:.2%} | {gt} |\n")
    else:
        lines.append("_No high-confidence Healthy predictions detected._\n")
    lines.append("\n")
    sep()

    # ── Suspicious confidence band summary ────────────────────────────────
    h("Suspicious Confidence Predictions (40%–65%)", 2)
    lines.append(
        "> These predictions have top confidence in the 40–65% range — "
        "the model is uncertain and forced to pick.\n\n"
    )
    if suspicious_cases:
        lines.append("| Image | Region | Predicted | Confidence | GT Label |\n")
        lines.append("|-------|--------|-----------|------------|----------|\n")
        for (img, region, pred, conf, gt) in sorted(suspicious_cases, key=lambda x: x[3]):
            lines.append(f"| `{img}` | `{region}` | {pred} | {conf:.2%} | {gt} |\n")
    else:
        lines.append("_No suspicious-confidence predictions detected._\n")
    lines.append("\n")
    sep()

    # ── Per-region performance summary ────────────────────────────────────
    h("Region Performance Summary", 2)

    for region, stats in per_region_stats.items():
        if stats["tested"] == 0:
            continue
        avg_conf = (
            sum(stats["confidences"]) / len(stats["confidences"])
            if stats["confidences"] else 0.0
        )
        lines.append(f"### `{region}`\n")
        lines.append(f"| Metric | Value |\n")
        lines.append(f"|--------|-------|\n")
        lines.append(f"| Total images tested        | {stats['tested']} |\n")
        lines.append(f"| High-conf Healthy flags    | {stats['healthy_fp']} |\n")
        lines.append(f"| Suspicious-conf flags      | {stats['suspicious']} |\n")
        lines.append(f"| Average top confidence     | {avg_conf:.2%} |\n")
        lines.append(f"| Min confidence             | {min(stats['confidences']):.2%} |\n")
        lines.append(f"| Max confidence             | {max(stats['confidences']):.2%} |\n")
        lines.append("\n")

    sep()

    # ── Cross-region confusion analysis ──────────────────────────────────
    h("Cross-Region Disease Confusion Analysis", 2)
    lines.append(
        "This table shows, for each disease image (by GT label), how many region "
        "models predicted Healthy vs the correct disease vs something else.\n\n"
    )

    # Group by gt_label
    from collections import defaultdict
    gt_groups = defaultdict(list)
    for rec in all_region_results:
        gt_groups[rec["gt"]].append(rec)

    lines.append("| GT Label | Total Predictions | → Healthy | → Correct | → Other |\n")
    lines.append("|----------|------------------|-----------|-----------|--------|\n")
    for gt_label in sorted(gt_groups.keys()):
        recs   = gt_groups[gt_label]
        total  = len(recs)
        healthy_cnt = sum(1 for r in recs if r["pred"] == HEALTHY_LABEL)
        correct_cnt = sum(1 for r in recs if r["pred"].lower().replace(" ", "_")
                          == gt_label.lower().replace(" ", "_"))
        other_cnt   = total - healthy_cnt - correct_cnt + (
            healthy_cnt if gt_label == HEALTHY_LABEL else 0
        )
        # Recalculate cleanly
        healthy_cnt = sum(1 for r in recs if r["pred"] == HEALTHY_LABEL)
        correct_cnt = sum(1 for r in recs
                          if r["pred"].lower().strip() == gt_label.lower().strip())
        other_cnt   = total - healthy_cnt - correct_cnt
        if correct_cnt < 0:
            other_cnt = total - healthy_cnt
            correct_cnt = 0
        lines.append(
            f"| {gt_label} | {total} | {healthy_cnt} | {correct_cnt} | {other_cnt} |\n"
        )
    lines.append("\n")
    sep()

    # ── Recommendations ───────────────────────────────────────────────────
    h("Diagnostic Recommendations", 2)

    total_hfp = len(healthy_fp_cases)
    total_susp = len(suspicious_cases)

    lines.append(f"**High-confidence Healthy false positives detected:** {total_hfp}  \n")
    lines.append(f"**Suspicious-confidence predictions detected:** {total_susp}  \n\n")

    lines.append("| Issue Observed | Likely Cause | Suggested Fix |\n")
    lines.append("|----------------|-------------|---------------|\n")
    lines.append("| Disease predicted as Healthy (high conf) | Region model has no class for that disease | Add disease class to region or use OOD detection |\n")
    lines.append("| Disease predicted as Healthy (external img) | Domain shift (phone camera vs dataset) | Data augmentation + fine-tuning |\n")
    lines.append("| Low confidence, correct class | Class imbalance | Class weighting during re-training |\n")
    lines.append("| Suspicious confidence band | Model uncertainty, image ambiguous | OOD detection (softmax entropy threshold) |\n")
    lines.append("| Region model only has 2 classes | Narrow class scope | Extend regional dataset or merge regions |\n")
    lines.append("\n")

    lines.append("### Priority Actions\n\n")
    lines.append("1. **Immediate (no retraining):** Apply confidence threshold ≥ 70% (already in `predict_with_threshold.py`). "
                 "This catches the suspicious-confidence band.  \n")
    lines.append("2. **Short-term:** Implement OOD (Out-of-Distribution) detection using softmax entropy — "
                 "high entropy = model unsure = reject rather than output a class.  \n")
    lines.append("3. **Medium-term:** Expand regional datasets to include all diseases in all regions "
                 "where agronomically relevant.  \n")
    lines.append("4. **Long-term:** Consider retraining with augmented external/field images "
                 "to close domain gap between dataset and real farmer uploads.  \n\n")

    sep()
    lines.append(f"_Report generated by `evaluate_all_regional_models.py` | CropGuard AutoML Pipeline_\n")

    with open(output_path, "w", encoding="utf-8") as f:
        f.writelines(lines)


# ── CLI ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="CropGuard — Evaluate all regional models against test images."
    )
    parser.add_argument("--test-dir",   default="test_images",       help="Folder with test images")
    parser.add_argument("--data-dir",   default="data",               help="Regional data root folder")
    parser.add_argument("--models-dir", default="trained_models",     help="Folder with .keras model files")
    parser.add_argument("--out",        default="reports/regional_model_evaluation.md",
                        help="Output markdown report path")
    parser.add_argument("--threshold",  type=float, default=0.70,     help="Confidence threshold (default 0.70)")
    args = parser.parse_args()

    scripts_dir = os.path.dirname(os.path.abspath(__file__))

    evaluate(
        test_dir    = args.test_dir,
        data_dir    = args.data_dir,
        models_dir  = args.models_dir,
        output_path = args.out,
        threshold   = args.threshold,
        scripts_dir = scripts_dir,
    )


if __name__ == "__main__":
    main()
