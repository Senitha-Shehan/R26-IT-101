import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input


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


MODEL_PATH = MODEL_PATH = "model_compression/float16_models/north_central_dry_zone_float16.tflite"
IMAGE_PATH = "test_images/BLB_1.jpg"


print("="*60)
print("CROPGUARD TFLITE COMPARISON TEST")
print("="*60)


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


# SAME PREPROCESSING AS FRIEND'S KERAS SCRIPT
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


print("\nPrediction:")
print(GLOBAL_CLASSES[idx])


print("\nConfidence:")
print(predictions[idx] * 100)



print("\nTop 3:")


for cls, prob in sorted(
    zip(GLOBAL_CLASSES, predictions),
    key=lambda x: x[1],
    reverse=True
)[:3]:

    print(
        f"{cls}: {prob:.2%}"
    )


print("="*60)