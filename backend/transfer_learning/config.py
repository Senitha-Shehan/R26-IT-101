import os

# Base paths
BASE_MODEL_PATH = "models/mobilenetv2_model.keras"
DATA_DIR = "data"
OUTPUT_DIR = "trained_models"

# Image & Data generator config
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
VALIDATION_SPLIT = 0.2

# Training hyper-parameters (initially frozen stage)
LEARNING_RATE = 1e-3

# Base model expected classes mapping
EXPECTED_CLASSES = [
    "Bacterial Leaf Blight",
    "Brown Spot",
    "Healthy Rice Leaf",
    "Leaf Blast",
    "Leaf Scald",
    "Narrow Brown Leaf Spot",
    "Rice Hispa",
    "Sheath Blight"
]
