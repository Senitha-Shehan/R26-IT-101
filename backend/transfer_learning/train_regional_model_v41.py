import os
import sys
import argparse
import random
import datetime
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from sklearn.metrics import classification_report, confusion_matrix

try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(os.path.join(PROJECT_ROOT, "scripts"))
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from load_member2_model_fixed import load_member2_model

random.seed(42)
np.random.seed(42)
tf.random.set_seed(42)

ALL_CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf Scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight"
]

CUSTOM_CLASS_WEIGHTS = {
    "Brown Spot": 1.3,
    "Narrow Brown Leaf Spot": 1.5,
    "Sheath Blight": 1.3
}

def detect_active_classes(dataset_path: str) -> list:
    """Return sorted list of class subfolders in dataset path."""
    if not os.path.exists(dataset_path):
        return ALL_CLASSES
    active = []
    image_extensions = ('.jpg', '.jpeg', '.png', '.bmp', '.webp')
    for d in sorted(os.listdir(dataset_path)):
        d_path = os.path.join(dataset_path, d)
        if os.path.isdir(d_path):
            img_count = sum(1 for f in os.listdir(d_path) if f.lower().endswith(image_extensions))
            if img_count > 0:
                name = d
                if name == "Leaf scald":
                    name = "Leaf Scald"
                active.append(name)
    return active if active else ALL_CLASSES

def load_v4_model_safe(v4_model_path: str) -> tf.keras.Model:
    """Load existing V4 regional model as baseline for V4.1 fine-tuning."""
    if not os.path.exists(v4_model_path):
        raise FileNotFoundError(f"V4 baseline model not found: {v4_model_path}")
    try:
        model = tf.keras.models.load_model(v4_model_path, compile=False)
        return model
    except Exception:
        return load_member2_model(v4_model_path)

def get_v41_class_weights(active_classes: list) -> dict:
    """Calculate custom class weights required for V4.1 active learning."""
    weight_dict = {}
    print("\nApplying V4.1 Custom Class Weights:")
    for idx, cls in enumerate(active_classes):
        weight = CUSTOM_CLASS_WEIGHTS.get(cls, 1.0)
        weight_dict[idx] = weight
        print(f"  - Class {idx} ('{cls}'): {weight:.2f}")
    return weight_dict

def train_v41_regional_model(region_name: str, dataset_path: str, v4_model_path: str, output_path: str, report_path: str):
    print("\n" + "="*60)
    print(f"STARTING CROPGUARD V4.1 FINE-TUNING FOR REGION: {region_name.upper()}")
    print("="*60)
    print(f"Dataset Path: {dataset_path}")
    print(f"Baseline V4 Model: {v4_model_path}")
    print(f"Output V4.1 Model: {output_path}")

    active_classes = detect_active_classes(dataset_path)
    num_classes = len(active_classes)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    os.makedirs(os.path.dirname(report_path), exist_ok=True)

    # 1. ImageDataGenerator Setup with requested V4.1 augmentation
    train_datagen = ImageDataGenerator(
        preprocessing_function=preprocess_input,
        validation_split=0.20,
        rotation_range=15,
        zoom_range=0.1,
        brightness_range=(0.9, 1.1),
        horizontal_flip=True
    )

    val_datagen = ImageDataGenerator(
        preprocessing_function=preprocess_input,
        validation_split=0.20
    )

    train_gen = train_datagen.flow_from_directory(
        dataset_path,
        target_size=(224, 224),
        batch_size=16,
        class_mode='categorical',
        classes=active_classes,
        subset='training',
        shuffle=True,
        seed=42
    )

    val_gen = val_datagen.flow_from_directory(
        dataset_path,
        target_size=(224, 224),
        batch_size=16,
        class_mode='categorical',
        classes=active_classes,
        subset='validation',
        shuffle=False
    )

    class_weight_dict = get_v41_class_weights(active_classes)

    # 2. Stage 1: Freeze Backbone & Train Head (5 Epochs, LR=1e-3)
    print("\n--- STAGE 1: Freeze Backbone & Train Head (5 Epochs, LR=1e-3) ---")
    model = load_v4_model_safe(v4_model_path)

    # Freeze MobileNetV2 backbone (freeze all except final Dense head layers)
    num_layers = len(model.layers)
    for i, layer in enumerate(model.layers):
        if i < num_layers - 2:  # Freeze everything except top classification layers
            layer.trainable = False
        else:
            layer.trainable = True

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    history_s1 = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=5,
        class_weight=class_weight_dict,
        verbose=1
    )

    # 3. Stage 2: Unfreeze Top 30 Layers & Fine-Tune (LR=1e-5)
    print("\n--- STAGE 2: Unfreeze Top 30 Layers & Fine-Tune (10 Epochs, LR=1e-5) ---")
    for layer in model.layers:
        layer.trainable = True

    num_layers = len(model.layers)
    for i, layer in enumerate(model.layers):
        if i < num_layers - 30:
            layer.trainable = False
        else:
            layer.trainable = True

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    callbacks_s2 = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=4,
            restore_best_weights=True,
            verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=output_path,
            monitor='val_loss',
            save_best_only=True,
            verbose=1
        )
    ]

    history_s2 = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=10,
        callbacks=callbacks_s2,
        class_weight=class_weight_dict,
        verbose=1
    )

    # 4. Final Evaluation & Save Report
    if not os.path.exists(output_path):
        model.save(output_path)

    print(f"\nEvaluating final V4.1 model checkpoint: {output_path}...")
    best_model = tf.keras.models.load_model(output_path, compile=False)
    best_model.compile(loss='categorical_crossentropy', metrics=['accuracy'])
    
    val_gen.reset()
    y_pred_probs = best_model.predict(val_gen, verbose=0)
    y_pred = np.argmax(y_pred_probs, axis=1)
    y_true = val_gen.classes

    eval_res = best_model.evaluate(val_gen, verbose=0)
    final_loss, final_acc = eval_res[0], eval_res[1]

    cm = confusion_matrix(y_true, y_pred)
    class_report_txt = classification_report(y_true, y_pred, target_names=active_classes, zero_division=0)

    # Generate Markdown Report
    lines = []
    lines.append(f"# CropGuard V4.1 Training Report — `{region_name}`")
    lines.append("")
    lines.append(f"**Generated:** {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append("")
    lines.append(f"- **Region**: `{region_name}`")
    lines.append(f"- **Saved Model**: `{output_path}`")
    lines.append(f"- **Base Model**: `{v4_model_path}`")
    lines.append(f"- **Stage 1 (Head)**: 5 Epochs, LR=1e-3")
    lines.append(f"- **Stage 2 (Top 30 Fine-tuning)**: EarlyStopping, LR=1e-5")
    lines.append(f"- **Final Validation Accuracy**: `{final_acc:.2%}`")
    lines.append(f"- **Final Validation Loss**: `{final_loss:.4f}`")
    lines.append("")
    lines.append("## Custom Class Weights Applied")
    lines.append("")
    for idx, weight in class_weight_dict.items():
        lines.append(f"- `{active_classes[idx]}`: {weight:.2f}")
    lines.append("")
    lines.append("## Classification Report")
    lines.append("```text")
    lines.append(class_report_txt)
    lines.append("```")
    lines.append("")
    lines.append("## Confusion Matrix")
    lines.append("")
    lines.append("| Actual \\ Predicted | " + " | ".join([f"`{c}`" for c in active_classes]) + " |")
    lines.append("| :--- | " + " | ".join(["---" for _ in active_classes]) + " |")
    for idx, row in enumerate(cm):
        lines.append(f"| `{active_classes[idx]}` | " + " | ".join([str(v) for v in row]) + " |")
    lines.append("")

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"[SUCCESS] Training completed for {region_name}! Model saved to {output_path}")
    return True

def main():
    parser = argparse.ArgumentParser(description="CropGuard V4.1 Fine-Tuning Script")
    parser.add_argument("--region", type=str, required=True, help="Region name")
    parser.add_argument("--dataset-path", type=str, required=True, help="Path to training dataset (e.g. data_v41/region)")
    parser.add_argument("--v4-model-path", type=str, required=True, help="Path to baseline V4 model")
    parser.add_argument("--output-path", type=str, required=True, help="Output V4.1 model path")
    parser.add_argument("--report-path", type=str, required=True, help="Report save path")

    args = parser.parse_args()
    train_v41_regional_model(
        region_name=args.region,
        dataset_path=args.dataset_path,
        v4_model_path=args.v4_model_path,
        output_path=args.output_path,
        report_path=args.report_path
    )

if __name__ == "__main__":
    main()
