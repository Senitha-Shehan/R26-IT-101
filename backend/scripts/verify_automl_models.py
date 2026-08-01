import os
import sys
import json
import tensorflow as tf

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

project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def main():
    print("============================================================")
    print("CROP GUARD AUTOML MODEL VERIFICATION SCRIPT")
    print("============================================================\n")
    
    all_passed = True
    summary_results = []
    
    for idx, region in enumerate(REGIONS, 1):
        print(f"[{idx}/{len(REGIONS)}] Checking region: {region}...")
        
        model_path = os.path.join(project_root, "automl_models", f"{region}_best_model.keras")
        report_path = os.path.join(project_root, "reports", f"{region}_automl_report.md")
        tuner_dir = os.path.join(project_root, "automl", f"tuner_results", region)
        json_path = os.path.join(project_root, "automl_results", f"{region}_best_hyperparameters.json")
        
        # 1. Check report
        report_ok = os.path.exists(report_path)
        if report_ok:
            print("  ✅ Report exists.")
        else:
            print("  ❌ Report missing!")
            all_passed = False
            
        # 2. Check tuner results folder
        tuner_ok = os.path.exists(tuner_dir) and os.path.isdir(tuner_dir)
        if tuner_ok:
            print("  ✅ Tuner results directory exists.")
        else:
            print("  ❌ Tuner results directory missing!")
            all_passed = False
            
        # 3. Check JSON
        json_ok = False
        dense_units = "N/A"
        dropout = "N/A"
        lr = "N/A"
        opt = "N/A"
        baseline_acc = "N/A"
        automl_acc = "N/A"
        training_time = "N/A"
        
        if os.path.exists(json_path):
            try:
                with open(json_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                dense_units = data.get("dense_units")
                dropout = data.get("dropout")
                lr = data.get("learning_rate")
                opt = data.get("optimizer")
                baseline_acc = f"{data.get('baseline_accuracy'):.4f}%"
                automl_acc = f"{data.get('automl_accuracy'):.4f}%"
                time_sec = data.get("training_time_seconds")
                training_time = f"{time_sec / 60.0:.2f} min"
                json_ok = True
                print("  ✅ Hyperparameter JSON parsed successfully.")
            except Exception as e:
                print(f"  ❌ Error parsing JSON: {e}")
                all_passed = False
        else:
            print("  ❌ Hyperparameter JSON missing!")
            all_passed = False
            
        # 4. Check model load
        model_ok = False
        if os.path.exists(model_path):
            try:
                # Load model with compile=False to avoid custom training logic issues
                model = tf.keras.models.load_model(model_path, compile=False)
                print(f"  ✅ Model loaded successfully (Input: {model.input_shape}, Output: {model.output_shape}).")
                model_ok = True
            except Exception as e:
                print(f"  ❌ Model failed to load: {e}")
                # Try fallback loaders if they exist
                try:
                    from load_member2_model_fixed import load_member2_model
                    model = load_member2_model(model_path)
                    print("  ✅ Model loaded successfully via fallback loader.")
                    model_ok = True
                except Exception as fe:
                    print(f"  ❌ Fallback loader also failed: {fe}")
                    all_passed = False
        else:
            print("  ❌ Model file missing!")
            all_passed = False
            
        summary_results.append({
            "region": region,
            "report_ok": report_ok,
            "tuner_ok": tuner_ok,
            "json_ok": json_ok,
            "model_ok": model_ok,
            "dense_units": dense_units,
            "dropout": dropout,
            "learning_rate": lr,
            "optimizer": opt,
            "baseline_accuracy": baseline_acc,
            "automl_accuracy": automl_acc,
            "training_time": training_time
        })
        print()
        
    print("============================================================")
    print("VERIFICATION SUMMARY")
    print("============================================================")
    print(f"| {'Region':<25} | {'Model':<5} | {'Report':<6} | {'Tuner':<5} | {'JSON':<5} | {'AutoML Acc':<10} |")
    print(f"| {'-'*25} | {'-'*5} | {'-'*6} | {'-'*5} | {'-'*5} | {'-'*10} |")
    for res in summary_results:
        print(f"| {res['region']:<25} | {'PASS' if res['model_ok'] else 'FAIL':<5} | {'PASS' if res['report_ok'] else 'FAIL':<6} | {'PASS' if res['tuner_ok'] else 'FAIL':<5} | {'PASS' if res['json_ok'] else 'FAIL':<5} | {res['automl_accuracy']:<10} |")
    print("============================================================\n")
    
    if all_passed:
        print("🎉 ALL CHECKS PASSED SUCCESSFULLY! CropGuard AutoML stage is complete.")
        sys.exit(0)
    else:
        print("❌ SOME CHECKS FAILED! Please inspect errors above.")
        sys.exit(1)

if __name__ == "__main__":
    main()
