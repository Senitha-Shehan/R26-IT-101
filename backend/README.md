# CropGuard: Edge AI Active Learning System for Real-Time Crop Disease Detection
## Novelty 4: Region-Adaptive AutoML Framework with Transfer Learning

This repository contains the deliverables for **Novelty 4: Region-Adaptive AutoML Framework with Transfer Learning**, a core component of the CropGuard Edge AI active learning system.

### Project Overview
The Region-Adaptive AutoML Framework resolves resource constraints on edge hardware by dynamically customizing classification heads according to disease prevalence in specific agricultural regions of Sri Lanka. Instead of running a heavy global 8-class model, CropGuard maps diseases to 9 distinct agricultural zones:
- **Central Highlands** (`central_highlands`)
- **Uva Zone** (`uva_zone`)
- **Eastern Dry Zone** (`eastern_dry_zone`)
- **North Central Dry Zone** (`north_central_dry_zone`)
- **Northern Dry Zone** (`northern_dry_zone`)
- **Northwestern Intermediate** (`northwestern_intermediate`)
- **Sabaragamuwa Zone** (`sabaragamuwa_zone`)
- **Southern Wet Zone** (`southern_wet_zone`)
- **Western Wet Zone** (`western_wet_zone`)

Reducing the classification search space from 8 classes to 2–4 classes per region simplifies model architecture, increases accuracy (achieving up to 100% validation accuracy), and prepares the model for high-efficiency TinyML compression.

---

### Folder Contents
The final deliverables for Novelty 4 are consolidated in `Novelty4_Final_Deliverables/` and structured as follows:

```
Novelty4_Final_Deliverables/
├── automl_models/                  # 9 Optimized Keras models (.keras format)
├── reports/                        # Detailed KerasTuner search reports for each region
├── regional_automl_summary.md      # Performance comparison (Baseline vs. AutoML)
├── handover_to_member1.md          # Model metadata, validation stats & hyperparameters
├── final_verification_report.md    # Verified inference results using sample images
└── README.md                       # This documentation file
```

---

### Model Loading Instructions
All regional models are saved in the Keras Bundle format (`.keras`). You can load any model using standard TensorFlow/Keras syntax.

#### Standard Keras Loading
```python
import tensorflow as tf

# Load the model without compiling to avoid custom training logic issues
model_path = "automl_models/central_highlands_best_model.keras"
model = tf.keras.models.load_model(model_path, compile=False)

print("Input Shape:", model.input_shape)   # (None, 224, 224, 3)
print("Output Shape:", model.output_shape) # (None, num_active_classes)
```

#### Fallback Loader
If you encounter loading errors due to Keras version inconsistencies (such as custom batch normalization properties or quantization configs in the archive), use the provided fallback loader:
```python
import sys
# Import fallback loader from load_member2_model_fixed.py
from load_member2_model_fixed import load_member2_model

model_path = "automl_models/central_highlands_best_model.keras"
model = load_member2_model(model_path)
```

---

### Specifications & Requirements

#### 1. Input Tensor Size
- **Resolution**: `224 × 224` pixels
- **Channels**: 3 (RGB)
- **Shape**: `(batch_size, 224, 224, 3)`

#### 2. Preprocessing
Before feeding images to the model, you **MUST** apply MobileNetV2 preprocessing. This rescales pixel values from `[0, 255]` to the `[-1, 1]` range.
```python
import numpy as np
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

# Load and resize
img = image.load_img("test_leaf.jpg", target_size=(224, 224))
img_array = image.img_to_array(img)
img_array = np.expand_dims(img_array, axis=0) # Add batch dimension

# Normalize using MobileNetV2 preprocess_input
preprocessed_img = preprocess_input(img_array)
```

#### 3. Expected Outputs & Classes
The output tensor is a softmax probability vector of shape `(batch_size, num_active_classes)`. The indices map to the active classes for that specific region, sorted **alphabetically**.

For example, for the **Central Highlands** region:
- Index `0`: `Healthy Rice Leaf`
- Index `1`: `Leaf Blast`

The exact list of active classes per region is documented in [handover_to_member1.md](file:///c:/Sliit/Year%204%20Semester%201/cropguard-regional-automl/handover_to_member1.md).

---

### Instructions for Member 1 (TinyML Compression)

To begin TinyML compression on the optimized regional models for hardware deployment (e.g., STM32, Arduino, or ESP32):

1. **Review Metadata**: Check [handover_to_member1.md](file:///c:/Sliit/Year%204%20Semester%201/cropguard-regional-automl/handover_to_member1.md) to identify the active class mapping and AutoML hyperparameters for each model.
2. **Setup TFLite Converter**:
   ```python
   import tensorflow as tf
   model = tf.keras.models.load_model("automl_models/central_highlands_best_model.keras", compile=False)
   converter = tf.lite.TFLiteConverter.from_keras_model(model)
   ```
3. **Apply Post-Training Quantization (PTQ)**:
   - **Float16 Quantization**:
     ```python
     converter.optimizations = [tf.lite.Optimize.DEFAULT]
     converter.target_spec.supported_types = [tf.float16]
     tflite_quant_model = converter.convert()
     ```
   - **Integer (INT8) Quantization**:
     Ensure you define a representative dataset generator using images from `data/{region}/` directory to calibrate the quantization scale parameters:
     ```python
     def representative_dataset_gen():
         # Load a subset of preprocessed images from the regional dataset
         # ...
         yield [preprocessed_img]
         
     converter.optimizations = [tf.lite.Optimize.DEFAULT]
     converter.representative_dataset = representative_dataset_gen
     converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
     converter.inference_input_type = tf.int8  # or tf.uint8
     converter.inference_output_type = tf.int8
     tflite_quant_model = converter.convert()
     ```
4. **Compile for Edge Target**:
   Use STM32Cube.AI or `xxd` to convert the `.tflite` model into a C++ byte array for deployment:
   ```bash
   xxd -i model.tflite > model_data.h
   ```
