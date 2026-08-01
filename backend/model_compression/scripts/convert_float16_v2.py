import tensorflow as tf
import os

input_model = "trained_models/v41/western_wet_zone_model.keras"

saved_model_path = "model_compression/temp_models/western_wet_zone_temp_saved_model"

output_model = "model_compression/float16_models/western_wet_zone_float16.tflite"


print("Loading Keras model...")

model = tf.keras.models.load_model(
    input_model,
    compile=False
)

print("Model loaded!")


print("Exporting SavedModel...")

model.export(saved_model_path)

print("SavedModel exported!")


print("Converting SavedModel to TFLite...")


converter = tf.lite.TFLiteConverter.from_saved_model(
    saved_model_path
)


converter.optimizations = [
    tf.lite.Optimize.DEFAULT
]

converter.target_spec.supported_types = [
    tf.float16
]


tflite_model = converter.convert()


with open(output_model, "wb") as f:
    f.write(tflite_model)


size_mb = os.path.getsize(output_model)/(1024*1024)

print("Conversion complete!")
print(f"Saved: {output_model}")
print(f"Size: {size_mb:.2f} MB")