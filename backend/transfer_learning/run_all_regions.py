import os
import sys
import subprocess

# Ensure UTF-8 output to prevent Windows console encoding issues
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

REGIONS = [
    "uva_zone",
    "eastern_dry_zone",
    "north_central_dry_zone",
    "northern_dry_zone",
    "northwestern_intermediate",
    "sabaragamuwa_zone",
    "southern_wet_zone",
    "western_wet_zone"
]

def main():
    # 1. Create directories
    os.makedirs("reports", exist_ok=True)
    os.makedirs("trained_models", exist_ok=True)
    
    python_exe = os.path.join(".venv", "Scripts", "python.exe")
    if not os.path.exists(python_exe):
        python_exe = "python"  # fallback to system python if venv not found
        
    print(f"Using python interpreter: {python_exe}")
    
    # 2. Iterate and train regions
    for idx, region in enumerate(REGIONS, 1):
        print("\n" + "="*80)
        print(f"[{idx}/{len(REGIONS)}] STARTING TRAINING FOR REGION: {region.upper()}")
        print("="*80)
        
        output_path = os.path.join("trained_models", f"{region}_model.keras")
        report_path = os.path.join("reports", f"{region}_training_report.md")
        
        cmd = [
            python_exe,
            "transfer_learning/train_regional_model.py",
            "--region", region,
            "--output-path", output_path,
            "--report-path", report_path,
            "--epochs", "10",
            "--train"
        ]
        
        print(f"Running command: {' '.join(cmd)}")
        
        # Execute training process and stream output to console
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )
        
        # Stream stdout in real-time
        for line in process.stdout:
            print(line, end="")
            
        process.wait()
        
        if process.returncode != 0:
            print(f"\n❌ Error: Training failed for region '{region}' with exit code {process.returncode}.")
            sys.exit(process.returncode)
            
        print(f"\n✅ Completed training for region '{region}'.")
        print(f"   Model saved to: {output_path}")
        print(f"   Report saved to: {report_path}")
        print("="*80 + "\n")
        
    print("🎉 All 8 regions trained successfully!")

if __name__ == "__main__":
    main()
