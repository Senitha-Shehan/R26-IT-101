import json
import os
import tempfile
import zipfile

from keras.saving import deserialize_keras_object


def clean_config(obj):
    if isinstance(obj, dict):
        for key in ["renorm", "renorm_clipping", "renorm_momentum", "quantization_config"]:
            obj.pop(key, None)
        for value in obj.values():
            clean_config(value)
    elif isinstance(obj, list):
        for item in obj:
            clean_config(item)


def load_member2_model(model_path):
    with zipfile.ZipFile(model_path, "r") as archive:
        config_data = json.loads(archive.read("config.json"))
        clean_config(config_data)
        model = deserialize_keras_object(config_data, safe_mode=False)

        weights_bytes = archive.read("model.weights.h5")
        with tempfile.NamedTemporaryFile(suffix=".weights.h5", delete=False) as tmp:
            tmp.write(weights_bytes)
            temp_weights_path = tmp.name

        try:
            model.load_weights(temp_weights_path)
        finally:
            if os.path.exists(temp_weights_path):
                os.remove(temp_weights_path)

    return model


if __name__ == "__main__":
    model = load_member2_model("models/mobilenetv2_model.keras")
    print("✅ Member 2 model loaded successfully")
    print(model.summary())
