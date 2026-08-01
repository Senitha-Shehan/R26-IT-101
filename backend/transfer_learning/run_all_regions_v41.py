import os
import sys
import subprocess

try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

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

def main():
    print("========================================")
    print("RUNNING CROPGUARD V4.1 BATCH TRAINING")
    print("========================================\n")

    python_executable = sys.executable
    train_script = os.path.join(PROJECT_ROOT, "transfer_learning", "train_regional_model_v41.py")
    data_v41_root = os.path.join(PROJECT_ROOT, "data_v41")
    v4_models_root = os.path.join(PROJECT_ROOT, "trained_models", "v4")
    v41_models_root = os.path.join(PROJECT_ROOT, "trained_models", "v41")
    v41_reports_root = os.path.join(PROJECT_ROOT, "reports", "v41")

    os.makedirs(v41_models_root, exist_ok=True)
    os.makedirs(v41_reports_root, exist_ok=True)

    for idx, region in enumerate(REGIONS, 1):
        v41_model_path = os.path.join(v41_models_root, f"{region}_model.keras")
        if os.path.exists(v41_model_path):
            print(f"[{idx}/{len(REGIONS)}] Region {region} already trained ({v41_model_path} exists). Skipping...")
            continue

        print(f"\n[{idx}/{len(REGIONS)}] Training V4.1 Model for region: {region}...")
        
        dataset_path = os.path.join(data_v41_root, region)
        v4_model_path = os.path.join(v4_models_root, f"{region}_model.keras")
        v41_report_path = os.path.join(v41_reports_root, f"{region}_v41_report.md")

        cmd = [
            python_executable,
            train_script,
            "--region", region,
            "--dataset-path", dataset_path,
            "--v4-model-path", v4_model_path,
            "--output-path", v41_model_path,
            "--report-path", v41_report_path
        ]

        res = subprocess.run(cmd, cwd=PROJECT_ROOT)
        if res.returncode != 0:
            print(f"ERROR: Training failed for region {region} with exit code {res.returncode}")
            sys.exit(res.returncode)

    print("\n========================================")
    print("ALL 9 V4.1 REGIONAL MODELS TRAINED SUCCESSFULLY!")
    print(f"Models saved in: {v41_models_root}")
    print(f"Reports saved in: {v41_reports_root}")
    print("========================================\n")

if __name__ == "__main__":
    main()
