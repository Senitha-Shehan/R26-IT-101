import os
import sys
import argparse
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from sklearn.metrics import classification_report, confusion_matrix

# Adjust path to find config and model_builder
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
import config
from model_builder import load_base_model, build_regional_model

def detect_active_classes(dataset_path):
    """
    Scans the regional dataset folder and detects which disease subfolders contain images.
    Returns the list of disease subfolders with at least 1 image.
    """
    if not os.path.exists(dataset_path):
        raise FileNotFoundError(f"Regional dataset directory not found: {dataset_path}")
        
    print(f"Scanning directory for active classes: {dataset_path}...")
    active_classes = []
    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp')
    
    # Inspect subdirectories
    for d in sorted(os.listdir(dataset_path)):
        d_path = os.path.join(dataset_path, d)
        if os.path.isdir(d_path):
            img_count = sum(
                1 for f in os.listdir(d_path)
                if f.lower().endswith(image_extensions)
            )
            if img_count > 0:
                active_classes.append((d, img_count))
                
    if not active_classes:
        raise ValueError(f"No image subfolders found in {dataset_path}")
        
    print(f"Detected {len(active_classes)} active classes containing images:")
    for name, count in active_classes:
        print(f"  - '{name}': {count} images")
        
    return [name for name, _ in active_classes]

def prepare_data_generators(dataset_path, active_classes):
    """Sets up the train and validation generators using MobileNetV2 preprocessing."""
    print("\nPreparing ImageDataGenerators with MobileNetV2 preprocessing...")
    
    datagen = ImageDataGenerator(
        preprocessing_function=preprocess_input,
        validation_split=config.VALIDATION_SPLIT
    )
    
    train_generator = datagen.flow_from_directory(
        dataset_path,
        target_size=config.IMAGE_SIZE,
        batch_size=config.BATCH_SIZE,
        class_mode='categorical',
        classes=active_classes,
        subset='training',
        shuffle=True
    )
    
    val_generator = datagen.flow_from_directory(
        dataset_path,
        target_size=config.IMAGE_SIZE,
        batch_size=config.BATCH_SIZE,
        class_mode='categorical',
        classes=active_classes,
        subset='validation',
        shuffle=False
    )
    
    return train_generator, val_generator

def verify_pipeline(region_name, dataset_path, base_model_path):
    """
    Runs a dry-run validation of the entire pipeline:
    1. Detects regional active classes
    2. Builds the region-adaptive model
    3. Initializes the data generators
    4. Passes a single batch of images through the model to verify output shape
    """
    print("\n" + "="*60)
    print(f"VERIFYING REGIONAL PIPELINE FOR: {region_name.upper()}")
    print("="*60)
    
    # 1. Detect classes
    active_classes = detect_active_classes(dataset_path)
    num_classes = len(active_classes)
    print(f"Expected model classification outputs: {num_classes}")
    
    # 2. Setup generators
    train_gen, val_gen = prepare_data_generators(dataset_path, active_classes)
    
    # Check generator properties
    print(f"Train samples: {train_gen.samples}")
    print(f"Validation samples: {val_gen.samples}")
    print(f"Class indices: {train_gen.class_indices}")
    
    # 3. Load and modify base model
    base_model = load_base_model(base_model_path)
    regional_model = build_regional_model(base_model, num_classes, config.LEARNING_RATE)
    
    # Print custom summary highlighting heads
    print("\nRegional Model Output Layer Configuration:")
    print(f"  Final Layer name: {regional_model.layers[-1].name}")
    print(f"  Final Layer output shape: {regional_model.layers[-1].output.shape}")
    print(f"  Final Layer trainable: {regional_model.layers[-1].trainable}")
    
    # 4. Dry run batch validation (forward-pass test)
    print("\nRunning test forward-pass using a batch from the training generator...")
    try:
        x_batch, y_batch = next(train_gen)
        print(f"  Input batch shape: {x_batch.shape}")
        print(f"  Target label batch shape: {y_batch.shape}")
        
        predictions = regional_model.predict(x_batch, verbose=0)
        print(f"  Output predictions batch shape: {predictions.shape}")
        
        # Verify predictions match label shape
        if predictions.shape == y_batch.shape:
            print("\nSUCCESS: Forward-pass shape verification completed successfully!")
            print(f"  Model output matches the target class dimensionality: {predictions.shape[1]}")
        else:
            print(f"\nERROR: Shape mismatch! Predictions shape {predictions.shape} vs Targets shape {y_batch.shape}")
            sys.exit(1)
            
    except Exception as e:
        print(f"\nERROR during dry-run batch inference: {e}")
        sys.exit(1)
        
    print("="*60 + "\n")
    return True

def train_and_evaluate_regional(region_name, dataset_path, base_model_path, epochs, output_path, report_path):
    """
    Loads model, prepares generators, adds EarlyStopping and ModelCheckpoint,
    trains the regional head, evaluates on validation, and generates a markdown report.
    """
    print("\n" + "="*60)
    print(f"STARTING TRAINING STAGE FOR REGION: {region_name.upper()}")
    print("="*60)
    
    # 1. Detect and setup datasets
    active_classes = detect_active_classes(dataset_path)
    num_classes = len(active_classes)
    
    train_gen, val_gen = prepare_data_generators(dataset_path, active_classes)
    
    # 2. Build model
    base_model = load_base_model(base_model_path)
    model = build_regional_model(base_model, num_classes, config.LEARNING_RATE)
    
    # Ensure parent output directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    # 3. Setup Callbacks
    early_stopping = tf.keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=3,
        restore_best_weights=True,
        verbose=1
    )
    
    model_checkpoint = tf.keras.callbacks.ModelCheckpoint(
        filepath=output_path,
        monitor='val_loss',
        save_best_only=True,
        verbose=1
    )
    
    # 4. Train the model
    print(f"\nTraining for {epochs} epochs (with frozen backbone)...")
    history = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=epochs,
        callbacks=[early_stopping, model_checkpoint],
        verbose=1
    )
    
    # 5. Load the best saved model weights for final evaluation
    print(f"\nLoading the best trained model checkpoint from {output_path}...")
    try:
        best_model = tf.keras.models.load_model(output_path, compile=False)
    except Exception as e:
        print(f"Could not load best model using keras load_model: {e}. Re-using current in-memory model.")
        best_model = model
        
    # 6. Evaluation and Predictions
    print("\nGenerating final evaluation predictions...")
    val_gen.reset()
    y_pred_probs = best_model.predict(val_gen, verbose=0)
    y_pred = np.argmax(y_pred_probs, axis=1)
    y_true = val_gen.classes
    
    # Final loss and accuracy evaluate
    best_model.compile(loss='categorical_crossentropy', metrics=['accuracy'])
    eval_results = best_model.evaluate(val_gen, verbose=0)
    final_val_loss = eval_results[0]
    final_val_acc = eval_results[1]
    
    # Classification report & Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    class_report_txt = classification_report(y_true, y_pred, target_names=active_classes)
    
    # Generate Training Report
    generate_markdown_report(
        region_name=region_name,
        active_classes=active_classes,
        history=history,
        final_loss=final_val_loss,
        final_acc=final_val_acc,
        cm=cm,
        class_report_txt=class_report_txt,
        report_path=report_path,
        output_model_path=output_path
    )
    
    print("\n" + "="*60)
    print(f"TRAINING COMPLETED FOR {region_name.upper()}!")
    print(f"Saved model to: {output_path}")
    print(f"Saved report to: {report_path}")
    print("="*60 + "\n")
    return True

def generate_markdown_report(region_name, active_classes, history, final_loss, final_acc, cm, class_report_txt, report_path, output_model_path):
    """Formats and writes the detailed training results to a Markdown file."""
    lines = []
    lines.append(f"# Regional Model Training Report - `{region_name}`")
    lines.append("")
    lines.append("This report summarizes the training metrics, curves, and validation scores for the region-adaptive classifier.")
    lines.append("")
    
    lines.append("## Model Metadata")
    lines.append("")
    lines.append(f"- **Region**: `{region_name}`")
    lines.append(f"- **Saved Model Path**: `{output_model_path}`")
    lines.append(f"- **Active Target Classes**: {', '.join([f'`{c}`' for c in active_classes])}")
    lines.append(f"- **Backbone Network**: `MobileNetV2` (frozen during training)")
    lines.append("")
    
    lines.append("## Training History")
    lines.append("")
    lines.append("| Epoch | Loss | Accuracy | Val Loss | Val Accuracy |")
    lines.append("| --- | --- | --- | --- | --- |")
    
    for i in range(len(history.history['loss'])):
        loss = history.history['loss'][i]
        acc = history.history['accuracy'][i]
        val_loss = history.history['val_loss'][i]
        val_acc = history.history['val_accuracy'][i]
        lines.append(f"| {i+1} | {loss:.4f} | {acc:.4f} | {val_loss:.4f} | {val_acc:.4f} |")
    lines.append("")
    
    lines.append("## Final Validation Metrics (Best Checkpoint)")
    lines.append("")
    lines.append(f"- **Validation Loss**: `{final_loss:.4f}`")
    lines.append(f"- **Validation Accuracy**: `{final_acc:.4%}`")
    lines.append("")
    
    lines.append("## Classification Report")
    lines.append("")
    lines.append("```text")
    lines.append(class_report_txt)
    lines.append("```")
    lines.append("")
    
    lines.append("## Confusion Matrix")
    lines.append("")
    
    # Render Confusion Matrix as Markdown Table
    lines.append("| Actual \\ Predicted | " + " | ".join([f"`{cls}`" for cls in active_classes]) + " |")
    lines.append("| --- | " + " | ".join(["---" for _ in active_classes]) + " |")
    for idx, row in enumerate(cm):
        lines.append(f"| `{active_classes[idx]}` | " + " | ".join([str(val) for val in row]) + " |")
    lines.append("")
    
    with open(report_path, mode='w', encoding='utf-8') as f:
        f.write("\n".join(lines))

def main():
    parser = argparse.ArgumentParser(description="Region-Adaptive Transfer Learning framework")
    parser.add_argument("--region", type=str, default="central_highlands", help="Name of agricultural region")
    parser.add_argument("--dataset-path", type=str, help="Custom path to the regional dataset (defaults to data/<region>)")
    parser.add_argument("--base-model", type=str, default=config.BASE_MODEL_PATH, help="Path to base model file")
    parser.add_argument("--epochs", type=int, default=10, help="Number of epochs to train")
    parser.add_argument("--output-path", type=str, help="Custom output model save path")
    parser.add_argument("--report-path", type=str, help="Custom training report save path")
    parser.add_argument("--verify-only", action="store_true", help="Only verify the pipeline structures without running training")
    parser.add_argument("--train", action="store_true", default=False, help="Initiate actual training")
    
    args = parser.parse_args()
    
    # Resolve default paths
    dataset_path = args.dataset_path or os.path.join(config.DATA_DIR, args.region)
    output_path = args.output_path or os.path.join(config.OUTPUT_DIR, f"{args.region}_model.keras")
    report_path = args.report_path or f"{args.region}_training_report.md"
    
    if args.train:
        train_and_evaluate_regional(
            region_name=args.region,
            dataset_path=dataset_path,
            base_model_path=args.base_model,
            epochs=args.epochs,
            output_path=output_path,
            report_path=report_path
        )
    elif args.verify_only:
        verify_pipeline(args.region, dataset_path, args.base_model)
    else:
        # Default to train if not specified otherwise, or ask
        # In this prompt environment, we make train the default since training has been explicitly requested
        train_and_evaluate_regional(
            region_name=args.region,
            dataset_path=dataset_path,
            base_model_path=args.base_model,
            epochs=args.epochs,
            output_path=output_path,
            report_path=report_path
        )

if __name__ == '__main__':
    main()
