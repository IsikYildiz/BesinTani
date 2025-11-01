import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import pathlib, json, os
from keras.applications import EfficientNetB3
from keras.applications.efficientnet import preprocess_input as efficientnet_preprocess
from keras.callbacks import ModelCheckpoint, ReduceLROnPlateau, EarlyStopping
from dotenv import load_dotenv

# Ayarlar
height, width = 256, 256
batch_Size = 16
load_dotenv()   
data_dir = pathlib.Path(os.getenv("dataset_path"))
model_path = "./model/efficientnetb3_food_model.keras"

# Modeli kaydetme
checkpoint_cb = ModelCheckpoint(
    model_path,
    monitor="val_accuracy",
    save_best_only=True,
    mode="max",
    verbose=1
)

# Mixed precision
from keras import mixed_precision
mixed_precision.set_global_policy('mixed_float16')

# Train ve validation setleri
train_ds = keras.utils.image_dataset_from_directory(
    data_dir,
    validation_split=0.2,
    subset="training",
    seed=1337,
    image_size=(height, width),
    batch_size=batch_Size,
)

val_ds = keras.utils.image_dataset_from_directory(
    data_dir,
    validation_split=0.2,
    subset="validation",
    seed=1337,
    image_size=(height, width),
    batch_size=batch_Size,
)

# Sınıf isimleri kaydedilir
class_names = train_ds.class_names
num_classes = len(class_names)
print("Sınıf sayısı:", num_classes)
with open("./model/class_names.json", "w") as f:
    json.dump(class_names, f)

# Yapay veri arttırımı
data_augmentation = keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.10),
    layers.RandomZoom(0.10),
    tf.keras.layers.RandomBrightness(0.1),
], name="data_augmentation")

# Uygula (augmentation CPU'da çalışır)
train_ds = train_ds.map(lambda x, y: (data_augmentation(x, training=True), y),
                        num_parallel_calls=tf.data.AUTOTUNE)

# Prefetch
train_ds = train_ds.prefetch(tf.data.AUTOTUNE)
val_ds = val_ds.prefetch(tf.data.AUTOTUNE)

# Base model
base_model = EfficientNetB3(weights="imagenet", include_top=False, input_shape=(height, width, 3))
base_model.trainable = False

# Learning rate schedule için steps_per_epoch al
card = tf.data.experimental.cardinality(train_ds)
try:
    steps_per_epoch = int(card.numpy())
except Exception:
    # fallback: tahmini adım sayısı
    steps_per_epoch = 2000

first_decay_steps = max(1, 2 * steps_per_epoch)

lr_schedule = tf.keras.optimizers.schedules.CosineDecayRestarts(
    initial_learning_rate=1e-4,
    first_decay_steps=first_decay_steps,
    t_mul=2.0,
    m_mul=0.8,
    alpha=1e-6
)
optimizer = tf.keras.optimizers.Adam(learning_rate=lr_schedule)

# Loss ve ön hazırlık
train_ds = train_ds.map(lambda x, y: (x, tf.one_hot(y, depth=num_classes)))
val_ds = val_ds.map(lambda x, y: (x, tf.one_hot(y, depth=num_classes)))
loss = tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1)

# Model tanımı 
inputs = layers.Input(shape=(height, width, 3))
x = efficientnet_preprocess(inputs)  
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.4)(x)
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = keras.Model(inputs, outputs)

model.compile(
    optimizer=optimizer,
    loss=loss,
    metrics=['accuracy']
)
model.summary()

# Callbacks
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.3, patience=2, min_lr=1e-7, verbose=1)
early_stop = EarlyStopping(monitor='val_accuracy', patience=4, restore_best_weights=True, verbose=1)

# Train 
history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=8,
    callbacks=[checkpoint_cb, reduce_lr, early_stop]
)

# Fine-tuning
base_model.trainable = True
for layer in base_model.layers[:-120]:
    layer.trainable = False

# Fine-tune için daha küçük LR
model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-5),
    loss=loss,
    metrics=["accuracy"]
)

history_fine = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=6,
    callbacks=[checkpoint_cb, reduce_lr, early_stop]
)
