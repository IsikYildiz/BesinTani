from tensorflow.keras.models import load_model
from keras.applications.efficientnet import preprocess_input
import numpy as np
from PIL import Image
import io
import json

with open("./model/class_names.json", "r") as f:
    class_names = json.load(f)
model = load_model(r"model/efficientnetb3_food_model.keras")

def predict_food(food_photo):
    # Veri hazırlama
    food_img = Image.open(io.BytesIO(food_photo)).convert("RGB").resize((256, 256))
    food_img_arr = np.array(food_img, dtype=np.float32) / 255.0
    food_img_arr = np.expand_dims(food_img_arr, axis=0)
    food_img_arr = preprocess_input(food_img_arr)

    # Tahmin
    prediction = model.predict(food_img_arr)
    index = np.argmax(prediction)
    confidence = float(np.max(prediction))

    # Sonucu dict olarak dön
    return {
        "label": class_names[index],
        "confidence": confidence
    }