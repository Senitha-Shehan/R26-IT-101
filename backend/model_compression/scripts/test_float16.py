import os
import sys
import shutil
import uuid
from datetime import datetime, timezone

# Ensure UTF-8 output to prevent Windows console encoding problems
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Ensure backend root directory is in sys.path
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input

from database.active_learning import save_uncertain_sample


GLOBAL_CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf Scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight"
]


MODEL_PATH = "model_compression/float16_models/sabaragamuwa_zone_float16.tflite"
IMAGE_PATH = "test_images/hrr.jpg"

CONFIDENCE_THRESHOLD = 0.80
UNCERTAIN_DIR = "data/uncertain_images"

REGION_NAME = "sabaragamuwa_zone"
MODEL_NAME = "sabaragamuwa_zone_float16"


print("=" * 60)
print("CROPGUARD TFLITE ACTIVE LEARNING TEST")
print("=" * 60)


print("\nLoading TFLite model...")

interpreter = tf.lite.Interpreter(
    model_path=MODEL_PATH
)

interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()


print("Input shape:")
print(input_details[0]["shape"])

print("Output shape:")
print(output_details[0]["shape"])


print("\nLoading image...")

img = image.load_img(
    IMAGE_PATH,
    target_size=(224, 224)
)

img_array = image.img_to_array(
    img
)

img_array = np.expand_dims(
    img_array,
    axis=0
)

img_array = preprocess_input(
    img_array
)


print("Input min/max:")
print(img_array.min(), img_array.max())


print("\nRunning inference...")

interpreter.set_tensor(
    input_details[0]["index"],
    img_array
)

interpreter.invoke()


predictions = interpreter.get_tensor(
    output_details[0]["index"]
)[0]


print("\nRAW TFLITE OUTPUT:")
print(predictions)


idx = np.argmax(predictions)

predicted_class = GLOBAL_CLASSES[idx]

confidence = float(predictions[idx])


print("\nPrediction:")
print(predicted_class)

print("\nConfidence:")
print(f"{confidence:.2%}")

print("\nConfidence Threshold:")
print(f"{CONFIDENCE_THRESHOLD:.0%}")


# ==========================================
# ACTIVE LEARNING
# ==========================================

if confidence < CONFIDENCE_THRESHOLD:

    print("\n⚠ LOW CONFIDENCE")
    print("Active Learning triggered.")

    os.makedirs(
        UNCERTAIN_DIR,
        exist_ok=True
    )

    timestamp = datetime.now(
        timezone.utc
    ).strftime("%Y%m%d_%H%M%S")

    unique_id = uuid.uuid4().hex[:8]

    extension = os.path.splitext(
        IMAGE_PATH
    )[1] or ".jpg"

    filename = (
        f"{timestamp}_{unique_id}{extension}"
    )

    destination = os.path.join(
        UNCERTAIN_DIR,
        filename
    )

    shutil.copy(
        IMAGE_PATH,
        destination
    )

    print("\nUncertain image saved:")
    print(destination)

    # Save metadata to MongoDB
    save_uncertain_sample(
        image_path=destination,
        predicted_disease=predicted_class,
        confidence=confidence,
        threshold=CONFIDENCE_THRESHOLD,
        region=REGION_NAME,
        model_name=MODEL_NAME
    )

else:

    print("\n✓ HIGH CONFIDENCE")
    print("Prediction accepted.")


# ==========================================
# TOP 3 PREDICTIONS
# ==========================================

print("\nTop 3:")

for cls, prob in sorted(
    zip(GLOBAL_CLASSES, predictions),
    key=lambda x: x[1],
    reverse=True
)[:3]:

    print(
        f"{cls}: {prob:.2%}"
    )


print("=" * 60)