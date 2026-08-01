"""
check_regional_classes.py
=========================
Verifies the CropGuard regional datasets (data/ and data_v2/) by scanning
every region folder and counting the images in each disease sub-folder.

Prints a human-readable report to stdout and (optionally) saves a
Markdown summary.

Usage
-----
python scripts/check_regional_classes.py
python scripts/check_regional_classes.py --data-dir data --data-v2-dir data_v2
python scripts/check_regional_classes.py --save-report reports/check_report.md

Does NOT modify any dataset or model files.
"""

import os
import sys
import argparse
from pathlib import Path

# Ensure UTF-8 output on Windows terminals
if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# ── Constants ─────────────────────────────────────────────────────────────────

ALL_9_REGIONS = [
    "central_highlands",
    "eastern_dry_zone",
    "north_central_dry_zone",
    "northern_dry_zone",
    "northwestern_intermediate",
    "sabaragamuwa_zone",
    "southern_wet_zone",
    "uva_zone",
    "western_wet_zone",
]

ALL_8_CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight",
]

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".JPG", ".JPEG", ".PNG", ".BMP"}

DEFAULT_DATA_DIR    = "data"
DEFAULT_DATA_V2_DIR = "data_v2"


# ── Helpers ───────────────────────────────────────────────────────────────────

def count_images(folder: Path) -> int:
    """Return the number of image files directly inside *folder*."""
    if not folder.is_dir():
        return 0
    return sum(
        1 for f in folder.iterdir()
        if f.is_file() and f.suffix in IMAGE_EXTENSIONS
    )


def scan_dataset(base_dir: str) -> dict:
    """
    Scan *base_dir* for region → disease → image-count.

    Returns
    -------
    results[region][disease] = int  (0 if folder is absent or empty)
    """
    base = Path(base_dir)
    results: dict[str, dict[str, int]] = {}

    for region in ALL_9_REGIONS:
        results[region] = {}
        for disease in ALL_8_CLASSES:
            disease_folder = base / region / disease
            results[region][disease] = count_images(disease_folder)

    return results


# ── Pretty-print helpers ──────────────────────────────────────────────────────

def status_icon(n_classes: int, target: int = 8) -> str:
    if n_classes == target:
        return "[OK]"
    elif n_classes >= target // 2:
        return "[PARTIAL]"
    else:
        return "[MISSING]"


def print_dataset_report(label: str, base_dir: str, results: dict) -> None:
    """Print a full per-region breakdown for one dataset."""
    exists = Path(base_dir).is_dir()

    print()
    print("=" * 62)
    print(f"  Dataset : {label}")
    print(f"  Path    : {base_dir}/")
    print(f"  Exists  : {'YES' if exists else 'NO — folder not found'}")
    print("=" * 62)

    if not exists:
        print("  (nothing to show)\n")
        return

    region_totals = {}

    for region in ALL_9_REGIONS:
        counts      = results[region]
        class_imgs  = {d: c for d, c in counts.items() if c > 0}
        n_classes   = len(class_imgs)
        total_imgs  = sum(counts.values())
        region_totals[region] = total_imgs
        icon        = status_icon(n_classes)

        print()
        print(f"  +-- {region}")
        print(f"  |   Total classes : {n_classes}/8  {icon}")
        print(f"  |   Total images  : {total_imgs}")
        print(f"  |")

        for disease in ALL_8_CLASSES:
            cnt   = counts[disease]
            mark  = "  " if cnt > 0 else "  ! "
            print(f"  |   {mark}{disease:<30}  {cnt:>5}")

        # Flag any diseases entirely missing
        missing = [d for d in ALL_8_CLASSES if counts[d] == 0]
        if missing:
            print(f"  |")
            print(f"  |   Missing / empty: {', '.join(missing)}")

        print(f"  +{'-' * 56}")

    # Region totals footer
    print()
    print("  Region image totals:")
    for region in ALL_9_REGIONS:
        print(f"    {region:<35}  {region_totals[region]:>6} images")


def print_comparison(
    results_old: dict | None,
    results_new: dict | None,
    dir_old: str,
    dir_new: str,
) -> None:
    """Side-by-side comparison table: data/ vs data_v2/."""

    old_exists = Path(dir_old).is_dir()
    new_exists = Path(dir_new).is_dir()

    print()
    print("=" * 70)
    print("  COMPARISON : data/ (old)  vs  data_v2/ (new)")
    print("=" * 70)
    print()

    # Header
    col = 34
    print(f"  {'Region':<{col}}  {'data/ classes':>14}  {'data_v2/ classes':>17}  Delta")
    print(f"  {'-'*col}  {'-'*14}  {'-'*17}  -----")

    for region in ALL_9_REGIONS:
        # classes with > 0 images
        if old_exists and results_old:
            n_old    = sum(1 for c in results_old[region].values() if c > 0)
            icon_old = status_icon(n_old)
        else:
            n_old    = "N/A"
            icon_old = ""

        if new_exists and results_new:
            n_new    = sum(1 for c in results_new[region].values() if c > 0)
            icon_new = status_icon(n_new)
        else:
            n_new    = "N/A"
            icon_new = ""

        # Delta indicator
        if isinstance(n_old, int) and isinstance(n_new, int):
            diff  = n_new - n_old
            delta = f"  +{diff}" if diff > 0 else (f"  -{abs(diff)}" if diff < 0 else "  =0")
        else:
            delta = ""

        old_str = f"{n_old}/8 {icon_old}"
        new_str = f"{n_new}/8 {icon_new}"
        print(f"  {region:<{col}}  {old_str:>14}  {new_str:>17}{delta}")

    print()
    print("  Legend:  [OK] = all 8 classes   [PARTIAL] = >=4   [MISSING] = <4")
    print()


# ── Markdown report ───────────────────────────────────────────────────────────

def save_markdown_report(
    results_old: dict | None,
    results_new: dict | None,
    dir_old: str,
    dir_new: str,
    report_path: str,
) -> None:
    """Write a compact Markdown summary to *report_path*."""
    os.makedirs(os.path.dirname(report_path) or ".", exist_ok=True)
    lines = []

    lines.append("# CropGuard Regional Dataset Check Report\n\n")
    lines.append("## Summary: data/ vs data_v2/\n\n")
    lines.append(
        "| Region | `data/` classes | `data_v2/` classes |\n"
        "|--------|----------------|--------------------|\n"
    )

    old_exists = Path(dir_old).is_dir()
    new_exists = Path(dir_new).is_dir()

    for region in ALL_9_REGIONS:
        n_old = (
            sum(1 for c in results_old[region].values() if c > 0)
            if old_exists and results_old else "N/A"
        )
        n_new = (
            sum(1 for c in results_new[region].values() if c > 0)
            if new_exists and results_new else "N/A"
        )
        icon_old = status_icon(n_old) if isinstance(n_old, int) else ""
        icon_new = status_icon(n_new) if isinstance(n_new, int) else ""
        lines.append(
            f"| `{region}` | {n_old}/8 {icon_old} | {n_new}/8 {icon_new} |\n"
        )

    lines.append("\n")

    for label, base_dir, results in [
        ("data/ (old)", dir_old, results_old),
        ("data_v2/ (new)", dir_new, results_new),
    ]:
        lines.append(f"## {label}\n\n")
        if not Path(base_dir).is_dir():
            lines.append(f"> Folder `{base_dir}/` not found.\n\n")
            continue

        # Per-region table
        for region in ALL_9_REGIONS:
            counts    = results[region]
            n_classes = sum(1 for c in counts.values() if c > 0)
            total     = sum(counts.values())
            icon      = status_icon(n_classes)

            lines.append(f"### `{region}` - {n_classes}/8 classes {icon} - {total} images\n\n")
            lines.append("| Disease | Images |\n|---------|--------|\n")
            for disease in ALL_8_CLASSES:
                lines.append(f"| {disease} | {counts[disease]} |\n")
            lines.append("\n")

    lines.append("---\n_Generated by `check_regional_classes.py` | CropGuard AutoML Pipeline_\n")


    with open(report_path, "w", encoding="utf-8") as f:
        f.writelines(lines)

    print(f"\n  📄 Markdown report saved → {report_path}")


# ── CLI ───────────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "CropGuard dataset verifier.\n"
            "Scans data/ and data_v2/ and reports per-region class coverage.\n"
            "Read-only — does NOT modify any files."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--data-dir",
        default=DEFAULT_DATA_DIR,
        help=f"Path to the OLD dataset root (default: {DEFAULT_DATA_DIR})",
    )
    parser.add_argument(
        "--data-v2-dir",
        default=DEFAULT_DATA_V2_DIR,
        help=f"Path to the NEW dataset root (default: {DEFAULT_DATA_V2_DIR})",
    )
    parser.add_argument(
        "--save-report",
        default=None,
        metavar="PATH",
        help="Optional path to save a Markdown summary report (e.g. reports/check_report.md)",
    )
    args = parser.parse_args()

    dir_old = args.data_dir
    dir_new = args.data_v2_dir

    print("\n  CropGuard — Regional Dataset Verification")
    print(f"  Checking : '{dir_old}/'  and  '{dir_new}/'")

    # Scan both datasets (None if folder absent)
    results_old = scan_dataset(dir_old) if Path(dir_old).is_dir() else None
    results_new = scan_dataset(dir_new) if Path(dir_new).is_dir() else None

    # ── Print individual reports ──────────────────────────────────────────
    print_dataset_report("data/ (old)", dir_old, results_old or {r: {d: 0 for d in ALL_8_CLASSES} for r in ALL_9_REGIONS})
    print_dataset_report("data_v2/ (new)", dir_new, results_new or {r: {d: 0 for d in ALL_8_CLASSES} for r in ALL_9_REGIONS})

    # ── Comparison table ──────────────────────────────────────────────────
    print_comparison(results_old, results_new, dir_old, dir_new)

    # ── Optional Markdown export ──────────────────────────────────────────
    if args.save_report:
        save_markdown_report(results_old, results_new, dir_old, dir_new, args.save_report)

    print("  Done. No files were modified.\n")


if __name__ == "__main__":
    main()
