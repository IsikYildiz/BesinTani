from tensorflow.keras.models import load_model
import numpy as np
from PIL import Image
import io
import json

def get_labels():
    with open(r"model/class_names.json", 'r') as file:
        data = json.load(file)
    return data

labels = get_labels()
model = load_model(r"model/efficientnetb3_food_model.keras")

def predict_food(food_photo):
    # Veri hazırlama
    food_img = Image.open(io.BytesIO(food_photo)).convert("RGB").resize((256, 256))
    food_img_arr = np.array(food_img, dtype=np.float32) / 255.0
    food_img_arr = np.expand_dims(food_img_arr, axis=0)

    # Tahmin
    prediction = model.predict(food_img_arr)
    index = np.argmax(prediction)
    confidence = float(np.max(prediction))

    # Sonucu dict olarak dön
    return {
        "label": labels[index],
        "confidence": confidence
    }