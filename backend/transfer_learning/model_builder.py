import sys
import os
import tensorflow as tf

def load_base_model(model_path):
    """Loads the pre-trained cropguard model and verifies its dimensions."""
    print(f"Loading base model from {model_path}...")
    try:
        model = tf.keras.models.load_model(model_path, compile=False)
    except Exception as exc:
        print(f"Standard load failed ({exc}). Using custom loader fallback...")
        # Append project root to sys.path
        project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        if project_root not in sys.path:
            sys.path.append(project_root)
        from load_member2_model_fixed import load_member2_model
        model = load_member2_model(model_path)
        
    print("Base model loaded successfully.")
    print(f"  Input shape: {model.input_shape}")
    print(f"  Output shape: {model.output_shape}")
    
    # Verify input shape is 224x224x3
    expected_input = (None, 224, 224, 3)
    if model.input_shape != expected_input:
        print(f"  Warning: Expected input shape {expected_input}, but found {model.input_shape}")
        
    return model

def build_regional_model(base_model, num_classes, learning_rate=1e-3):
    """
    Creates a new transfer learning model by extracting the pre-trained feature extractor,
    freezing the base layers, and adding a new classification head suitable for the target region.
    """
    print(f"Building region-adaptive model with classification head for {num_classes} classes...")
    
    # Extract the features before the final classification head
    last_layer = base_model.layers[-1]
    if isinstance(last_layer, tf.keras.layers.Dense):
        # Extract features feeding into the last dense layer
        features = last_layer.input
    else:
        # Fallback to second-to-last layer output
        features = base_model.layers[-2].output
        
    print(f"  Feature representation tensor: {features.name} (shape: {features.shape})")
    
    # Add a brand new classification head adapted to the regional classes
    predictions = tf.keras.layers.Dense(
        num_classes,
        activation='softmax',
        name='regional_classification_head'
    )(features)
    
    # Instantiate the new Functional model
    regional_model = tf.keras.Model(inputs=base_model.input, outputs=predictions)
    
    # Freeze the base backbone layers to preserve fine-tuned crop disease features
    print("  Freezing base layers...")
    for layer in regional_model.layers[:-1]:
        layer.trainable = False
        
    # Verify that only the last layer is trainable
    trainable_count = sum([1 for l in regional_model.layers if l.trainable])
    print(f"  Trainable layers count: {trainable_count} (should be 1)")
    
    # Compile the model
    regional_model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=learning_rate),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return regional_model
