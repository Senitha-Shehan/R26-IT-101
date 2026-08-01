import tensorflow as tf

model = tf.keras.models.load_model(
    "trained_models/v41/north_central_dry_zone_model.keras",
    compile=False
)

print("MODEL_LOADED_OK")
print("Input:", model.input_shape)
print("Output:", model.output_shape)