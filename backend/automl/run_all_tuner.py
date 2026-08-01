import os
import sys
import subprocess
import re

# Ensure UTF-8 output
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

project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def bootstrap_hyperparameters_json(region):
    results_dir = os.path.join(project_root, "automl_results")
    os.makedirs(results_dir, exist_ok=True)
    json_path = os.path.join(results_dir, f"{region}_best_hyperparameters.json")
    
    if os.path.exists(json_path):
        return  # already exists
        
    report_path = os.path.join(project_root, "reports", f"{region}_automl_report.md")
    if not os.path.exists(report_path):
        print(f"Warning: Cannot bootstrap JSON for {region} - report not found.")
        return
        
    try:
        with open(report_path, "r", encoding="utf-8") as f:
            content = f.read()
            
        # Parse baseline, automl accuracy, parameters, time
        baseline_match = re.search(r"\|\s*\*\*Before AutoML \(Stage 5\)\*\*\s*\|\s*([\d.]+)%?\s*\|", content)
        baseline_acc = float(baseline_match.group(1)) if baseline_match else 0.0
        
        automl_match = re.search(r"\|\s*\*\*After AutoML \(Stage 6\)\*\*\s*\|\s*\*\*?([\d.]+)%?\*\*?\s*\|", content)
        automl_acc = float(automl_match.group(1)) if automl_match else 0.0
        
        dense_match = re.search(r"-\s*\*\*Dense Head Units\*\*:\s*`(\d+)`", content)
        dropout_match = re.search(r"-\s*\*\*Dropout Rate\*\*:\s*`([\d.]+)`", content)
        lr_match = re.search(r"-\s*\*\*Learning Rate\*\*:\s*`([\d.]+)`", content)
        opt_match = re.search(r"-\s*\*\*Optimizer\*\*:\s*`([\w.]+)`", content)
        
        dense = int(dense_match.group(1)) if dense_match else 0
        dropout = float(dropout_match.group(1)) if dropout_match else 0.0
        lr = float(lr_match.group(1)) if lr_match else 0.0
        opt = str(opt_match.group(1)) if opt_match else "Unknown"
        
        time_sec_match = re.search(r"\(([\d.]+)\s*seconds\)", content)
        training_time_sec = float(time_sec_match.group(1)) if time_sec_match else 0.0
        if training_time_sec == 0.0:
            time_min_match = re.search(r"-\s*\*\*Total Training Time\*\*:\s*`([\d.]+)\s*minutes`", content)
            training_time_sec = float(time_min_match.group(1)) * 60.0 if time_min_match else 0.0
            
        json_data = {
            "region": region,
            "dense_units": dense,
            "dropout": dropout,
            "learning_rate": lr,
            "optimizer": opt,
            "baseline_accuracy": baseline_acc,
            "automl_accuracy": automl_acc,
            "training_time_seconds": training_time_sec
        }
        
        print(f"Bootstrapping missing hyperparameters JSON for '{region}' at {json_path}...")
        import json
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(json_data, f, indent=4)
    except Exception as e:
        print(f"Error bootstrapping JSON for '{region}': {e}")

def generate_global_summary():
    print("\nGenerating global AutoML summary report: regional_automl_summary.md...")
    table_lines = [
        "# CropGuard: Regional AutoML Optimization Summary Report",
        "",
        "This report summarizes the performance improvements achieved by the KerasTuner AutoML framework across all 9 agricultural zones of Sri Lanka. Each regional model has been optimized with a tailored classification head.",
        "",
        "## Performance Comparison Table",
        "",
        "| Region | Baseline Accuracy | AutoML Accuracy | Improvement | Dense Units | Dropout | Learning Rate | Optimizer | Training Time |",
        "| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |"
    ]
    
    import json
    for region in REGIONS:
        json_path = os.path.join(project_root, "automl_results", f"{region}_best_hyperparameters.json")
        if not os.path.exists(json_path):
            bootstrap_hyperparameters_json(region)
            
        if not os.path.exists(json_path):
            print(f"Warning: JSON file {json_path} missing. Skipping from summary.")
            continue
            
        try:
            with open(json_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                
            region_name = data.get("region", region).replace("_", " ").title()
            baseline_acc = f"{data.get('baseline_accuracy'):.4f}%"
            automl_acc = f"{data.get('automl_accuracy'):.4f}%"
            
            improvement_val = data.get('automl_accuracy') - data.get('baseline_accuracy')
            improvement = f"{improvement_val:+.4f}%"
            
            dense_units = str(data.get('dense_units'))
            dropout = f"{data.get('dropout'):.2f}"
            learning_rate = str(data.get('learning_rate'))
            optimizer = str(data.get('optimizer'))
            
            time_sec = data.get('training_time_seconds')
            time_min = time_sec / 60.0
            training_time = f"{time_min:.2f} minutes ({time_sec:.1f}s)"
            
            table_lines.append(
                f"| **{region_name}** | {baseline_acc} | **{automl_acc}** | **{improvement}** | {dense_units} | {dropout} | {learning_rate} | {optimizer} | {training_time} |"
            )
        except Exception as e:
            print(f"Error reading JSON summary for region '{region}': {e}")
            
    summary_path = os.path.join(project_root, "regional_automl_summary.md")
    with open(summary_path, "w", encoding="utf-8") as f:
        f.write("\n".join(table_lines) + "\n")
        
    print(f"Global summary written successfully to {summary_path}!")

def main():
    python_exe = os.path.join(project_root, ".venv", "Scripts", "python.exe")
    if not os.path.exists(python_exe):
        python_exe = "python"
        
    print(f"Using python interpreter: {python_exe}")
    
    # Run tuner sequentially for each of the regions
    for idx, region in enumerate(REGIONS, 1):
        model_path = os.path.join(project_root, "automl_models", f"{region}_best_model.keras")
        report_path = os.path.join(project_root, "reports", f"{region}_automl_report.md")
        if os.path.exists(model_path) and os.path.exists(report_path):
            print("\n" + "="*80)
            print(f"[{idx}/{len(REGIONS)}] SKIPPING REGION: {region.upper()} (Already Completed)")
            print("="*80 + "\n")
            bootstrap_hyperparameters_json(region)
            continue
            
        print("\n" + "="*80)
        print(f"[{idx}/{len(REGIONS)}] STARTING BATCH TUNING FOR: {region.upper()}")
        print("="*80)
        
        cmd = [
            python_exe,
            "automl/run_tuner.py",
            "--region", region,
            "--max-trials", "10",
            "--epochs", "10"
        ]
        
        print(f"Running command: {' '.join(cmd)}")
        
        # Execute tuning process and stream output to console
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            bufsize=1
        )
        
        # Stream stdout in real-time
        for line in process.stdout:
            print(line, end="")
            
        process.wait()
        
        if process.returncode != 0:
            print(f"\n❌ Error: Tuning failed for region '{region}' with exit code {process.returncode}.")
            sys.exit(process.returncode)
            
        print(f"\n✅ Completed tuning for region '{region}'.")
        print("="*80 + "\n")
        
    print("🎉 All 8 regional KerasTuner searches completed successfully!")
    
    # Generate final summary report
    generate_global_summary()

if __name__ == "__main__":
    main()
