import tensorflow as tf
from tensorflow.keras import layers, models
try:
    import kerastuner as kt
except ImportError:
    import keras_tuner as kt

from load_member2_model_fixed import load_member2_model


def build_tunable_model(hp, base_model_path, num_classes=6):
    base_model = load_member2_model(base_model_path)
    base_model.trainable = False

    if len(base_model.layers) >= 2 and isinstance(base_model.layers[-1], tf.keras.layers.Dense):
        feature_output = base_model.layers[-2].output
    else:
        feature_output = base_model.output

    x = layers.Dropout(
        hp.Float('dropout', 0.2, 0.5, step=0.1),
        name='tuner_dropout'
    )(feature_output)
    x = layers.Dense(
        hp.Int('dense_units', 64, 256, step=64),
        activation='relu',
        name='tuner_dense'
    )(x)
    outputs = layers.Dense(
        num_classes,
        activation='softmax',
        name='tuner_output'
    )(x)

    model = models.Model(inputs=base_model.input, outputs=outputs, name='tuner_model')
    model.compile(
        optimizer=tf.keras.optimizers.Adam(
            learning_rate=hp.Choice('learning_rate', [1e-2, 1e-3, 1e-4])
        ),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )

    return model


def get_tuner(region_name, base_model_path, num_classes):
    def build_model_for_tuner(hp):
        return build_tunable_model(hp, base_model_path, num_classes)

    tuner = kt.RandomSearch(
        build_model_for_tuner,
        objective='val_accuracy',
        max_trials=5,
        executions_per_trial=1,
        directory='tuner_results',
        project_name=f'region_{region_name}'
    )
    return tuner
