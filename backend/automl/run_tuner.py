import os
import sys
import argparse
import time
import re
import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models

# Ensure UTF-8 output to prevent Windows console encoding issues
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Setup paths to import transfer_learning scripts
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if project_root not in sys.path:
    sys.path.append(project_root)

from transfer_learning.model_builder import load_base_model
from transfer_learning.train_regional_model import detect_active_classes, prepare_data_generators

try:
    import keras_tuner as kt
except ImportError:
    import kerastuner as kt

def get_baseline_accuracy(region_name):
    """Retrieves baseline validation accuracy from Stage 5 report if it exists."""
    # Central highlands report is at the root
    if region_name == "central_highlands":
        report_path = os.path.join(project_root, "central_highlands_training_report.md")
    else:
        report_path = os.path.join(project_root, "reports", f"{region_name}_training_report.md")
        
    if os.path.exists(report_path):
        try:
            with open(report_path, "r", encoding="utf-8") as f:
                content = f.read()
            # Look for: - **Validation Accuracy**: `97.8261%`
            match = re.search(r"-\s*\*\*Validation Accuracy\*\*:\s*`([\d.]+)%?`", content)
            if match:
                return float(match.group(1)) / 100.0
            
            # Alternative format search
            match_acc = re.search(r"\|\s*10\s*\|[^|]+\|[^|]+\|[^|]+\|\s*([\d.]+)\s*\|", content)
            if match_acc:
                return float(match_acc.group(1))
        except Exception as e:
            print(f"Warning: Failed to parse baseline report: {e}")
            
    print(f"Using default fallback baseline validation accuracy for {region_name} (0.978261)")
    return 0.978261

def build_tunable_hypermodel(hp, base_model_path, num_classes):
    """Builds a tunable model with frozen backbone and search space on classification head."""
    base_model = load_base_model(base_model_path)
    
    # Freeze backbone
    for layer in base_model.layers:
        layer.trainable = False
        
    # Extract features before original dense head
    last_layer = base_model.layers[-1]
    if isinstance(last_layer, tf.keras.layers.Dense):
        features = last_layer.input
    else:
        features = base_model.layers[-2].output
        
    # Search Space defined in requirements:
    # Dense layer units: 64, 128, 256, 512
    dense_units = hp.Choice('dense_units', [64, 128, 256, 512])
    # Dropout: 0.2, 0.3, 0.5
    dropout_rate = hp.Choice('dropout', [0.2, 0.3, 0.5])
    # Learning rate: 0.001, 0.0001
    learning_rate = hp.Choice('learning_rate', [0.001, 0.0001])
    # Optimizer: Adam, RMSprop
    optimizer_name = hp.Choice('optimizer', ['Adam', 'RMSprop'])
    
    # Classification Head
    x = layers.Dropout(dropout_rate, name='tuner_dropout')(features)
    x = layers.Dense(dense_units, activation='relu', name='tuner_dense')(x)
    predictions = layers.Dense(num_classes, activation='softmax', name='tuner_output')(x)
    
    model = models.Model(inputs=base_model.input, outputs=predictions, name='tuner_model')
    
    if optimizer_name == 'Adam':
        optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate)
    else:
        optimizer = tf.keras.optimizers.RMSprop(learning_rate=learning_rate)
        
    model.compile(
        optimizer=optimizer,
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def main():
    parser = argparse.ArgumentParser(description="KerasTuner AutoML Optimization for CropGuard")
    parser.add_argument("--region", type=str, default="central_highlands", help="Region name")
    parser.add_argument("--base-model-path", type=str, default="models/mobilenetv2_model.keras", help="Path to base model")
    parser.add_argument("--dataset-dir", type=str, default="data", help="Directory containing datasets")
    parser.add_argument("--max-trials", type=int, default=10, help="Maximum search trials")
    parser.add_argument("--epochs", type=int, default=10, help="Epochs per trial training")
    parser.add_argument("--tuner-dir", type=str, default="automl/tuner_results", help="Directory to save tuner logs")
    
    args = parser.parse_args()
    
    print("\n" + "="*80)
    print(f"STARTING AUTOML HYPERPARAMETER TUNING FOR: {args.region.upper()}")
    print("="*80)
    
    # 1. Resolve paths
    dataset_path = os.path.join(project_root, args.dataset_dir, args.region)
    base_model_path = os.path.join(project_root, args.base_model_path)
    
    # 2. Detect active classes and prepare data
    active_classes = detect_active_classes(dataset_path)
    num_classes = len(active_classes)
    train_gen, val_gen = prepare_data_generators(dataset_path, active_classes)
    
    # Get baseline accuracy for comparison
    baseline_val_acc = get_baseline_accuracy(args.region)
    print(f"Baseline Validation Accuracy (Stage 5): {baseline_val_acc:.4%}")
    
    # 3. Initialize tuner
    tuner_project_name = args.region
    tuner_dir_path = os.path.join(project_root, args.tuner_dir)
    
    # Clear directory if it exists to ensure fresh search
    tuner_project_dir = os.path.join(tuner_dir_path, tuner_project_name)
    if os.path.exists(tuner_project_dir):
        print(f"Clearing existing tuner directory: {tuner_project_dir}")
        try:
            import shutil
            shutil.rmtree(tuner_project_dir)
        except Exception as e:
            print(f"Warning: Failed to clear tuner directory: {e}")

    tuner = kt.RandomSearch(
        hypermodel=lambda hp: build_tunable_hypermodel(hp, base_model_path, num_classes),
        objective='val_accuracy',
        max_trials=args.max_trials,
        executions_per_trial=1,
        directory=tuner_dir_path,
        project_name=tuner_project_name,
        overwrite=True
    )
    
    # 4. Run Search
    print("\n" + "-"*50)
    print(f"Executing KerasTuner Search ({args.max_trials} trials, {args.epochs} epochs each)...")
    print("-"*50)
    
    start_time = time.time()
    
    early_stopping = tf.keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=3,
        restore_best_weights=True
    )
    
    tuner.search(
        train_gen,
        validation_data=val_gen,
        epochs=args.epochs,
        callbacks=[early_stopping],
        verbose=1
    )
    
    end_time = time.time()
    total_training_time_sec = end_time - start_time
    total_training_time_min = total_training_time_sec / 60.0
    
    print("\nSearch complete!")
    print(f"Total training time: {total_training_time_min:.2f} minutes ({total_training_time_sec:.1f} seconds)")
    
    # 5. Extract Best Model & Hyperparameters
    best_hps = tuner.get_best_hyperparameters(num_trials=1)[0]
    print("\nBest Hyperparameters Found:")
    print(f"  Dense Units:   {best_hps.get('dense_units')}")
    print(f"  Dropout Rate:  {best_hps.get('dropout')}")
    print(f"  Learning Rate: {best_hps.get('learning_rate')}")
    print(f"  Optimizer:     {best_hps.get('optimizer')}")
    
    print("\nLoading and evaluating best model...")
    best_models = tuner.get_best_models(num_models=1)
    if not best_models:
        print("Error: Could not retrieve best model from KerasTuner.")
        sys.exit(1)
    best_model = best_models[0]
    
    # Compile and evaluate best model on validation generator
    best_model.compile(
        optimizer=best_model.optimizer,
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    val_loss, best_val_acc = best_model.evaluate(val_gen, verbose=0)
    print(f"Best Model Validation Accuracy: {best_val_acc:.4%}")
    print(f"Best Model Validation Loss:     {val_loss:.4f}")
    
    # Calculate improvement
    improvement = best_val_acc - baseline_val_acc
    improvement_percentage = improvement * 100.0
    
    # 6. Save best model
    automl_models_dir = os.path.join(project_root, "automl_models")
    os.makedirs(automl_models_dir, exist_ok=True)
    best_model_save_path = os.path.join(automl_models_dir, f"{args.region}_best_model.keras")
    
    print(f"\nSaving best model to {best_model_save_path}...")
    best_model.save(best_model_save_path)
    print("Best model saved successfully!")
    
    # 7. Parse trial results dynamically for the report
    trial_results_table = []
    tuner_project_dir = os.path.join(tuner_dir_path, tuner_project_name)
    if os.path.exists(tuner_project_dir):
        trial_results_table.append("| Trial ID | Dense Units | Dropout Rate | Learning Rate | Optimizer | Validation Accuracy |")
        trial_results_table.append("| :---: | :---: | :---: | :---: | :---: | :---: |")
        
        # Scan trial directories
        trial_dirs = sorted([d for d in os.listdir(tuner_project_dir) if d.startswith("trial_") and os.path.isdir(os.path.join(tuner_project_dir, d))])
        for td in trial_dirs:
            trial_json_path = os.path.join(tuner_project_dir, td, "trial.json")
            if os.path.exists(trial_json_path):
                try:
                    import json
                    with open(trial_json_path, 'r', encoding='utf-8') as f:
                        data = json.load(f)
                    t_id = data.get("trial_id", td.replace("trial_", ""))
                    hps = data.get("hyperparameters", {}).get("values", {})
                    score = data.get("score", 0.0)
                    trial_results_table.append(
                        f"| {t_id} | {hps.get('dense_units')} | {hps.get('dropout')} | {hps.get('learning_rate')} | {hps.get('optimizer')} | {score:.4%} |"
                    )
                except Exception as e:
                    print(f"Warning: Could not parse trial file {trial_json_path}: {e}")

    # 8. Generate markdown report
    reports_dir = os.path.join(project_root, "reports")
    os.makedirs(reports_dir, exist_ok=True)
    automl_report_path = os.path.join(reports_dir, f"{args.region}_automl_report.md")
    
    print(f"Generating AutoML report at {automl_report_path}...")
    
    report_lines = [
        f"# KerasTuner AutoML Optimization Report - `{args.region}`",
        "",
        "This report summarizes the AutoML hyperparameter search and optimization results for the regional classifier.",
        "",
        "## Summary Metrics",
        "",
        f"- **Region**: `{args.region}`",
        f"- **Best Model Saved Path**: `automl_models/{args.region}_best_model.keras`",
        f"- **Active Classes**: {', '.join([f'`{cls}`' for cls in active_classes])}",
        f"- **Total Training Time**: `{total_training_time_min:.2f} minutes` (`{total_training_time_sec:.1f} seconds`)",
        "",
        "## Performance Comparison",
        "",
        "| Phase | Validation Accuracy | Validation Loss |",
        "| :--- | :---: | :---: |",
        f"| **Before AutoML (Stage 5)** | {baseline_val_acc:.4%} | - |",
        f"| **After AutoML (Stage 6)** | **{best_val_acc:.4%}** | **{val_loss:.4f}** |",
        f"| **Absolute Improvement** | **{improvement_percentage:+.4f}%** | - |",
        "",
        "## Best Hyperparameters",
        "",
        "The following optimal configuration was discovered by KerasTuner:",
        "",
        f"- **Dense Head Units**: `{best_hps.get('dense_units')}`",
        f"- **Dropout Rate**: `{best_hps.get('dropout')}`",
        f"- **Learning Rate**: `{best_hps.get('learning_rate')}`",
        f"- **Optimizer**: `{best_hps.get('optimizer')}`",
        ""
    ]
    
    if trial_results_table:
        report_lines.extend([
            "",
            "## Trial Search Results",
            "",
            "\n".join(trial_results_table),
            ""
        ])
        
    report_lines.extend([
        "",
        "## Tuning Log / Search Details",
        "",
        f"- **Tuner Logs Directory**: `{args.tuner_dir}/{tuner_project_name}/`",
        f"- **Tuner Type**: `keras_tuner.RandomSearch`",
        f"- **Total Trials Run**: `{args.max_trials}`",
        f"- **Epochs Per Trial**: `{args.epochs}` (with EarlyStopping, patience=3)",
        f"- **Objective**: `val_accuracy` (maximize)",
        ""
    ])
    
    with open(automl_report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report_lines))
        
    # 8.5 Save best hyperparameters to JSON
    import json
    results_dir = os.path.join(project_root, "automl_results")
    os.makedirs(results_dir, exist_ok=True)
    json_path = os.path.join(results_dir, f"{args.region}_best_hyperparameters.json")
    
    json_data = {
        "region": args.region,
        "dense_units": int(best_hps.get('dense_units')),
        "dropout": float(best_hps.get('dropout')),
        "learning_rate": float(best_hps.get('learning_rate')),
        "optimizer": str(best_hps.get('optimizer')),
        "baseline_accuracy": float(round(baseline_val_acc * 100.0, 4)),
        "automl_accuracy": float(round(best_val_acc * 100.0, 4)),
        "training_time_seconds": float(round(total_training_time_sec, 2))
    }
    
    print(f"Saving best hyperparameters JSON to {json_path}...")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(json_data, f, indent=4)
        
    print("\n" + "="*80)
    print("AUTOML OPTIMIZATION COMPLETED SUCCESSFULLY!")
    print(f"Report location: {automl_report_path}")
    print("="*80 + "\n")

if __name__ == "__main__":
    main()
