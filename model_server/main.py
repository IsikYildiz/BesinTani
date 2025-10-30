from flask import Flask, request, jsonify
from model import predict_food
import base64

app = Flask(__name__)

# Yemek tahmin eder
@app.route('/')
def predict():
    # Gelen fotoğrafı byte haline getir
    photo_b64 = request.json.get("image")  
    photo_bytes = base64.b64decode(photo_b64)

    try:
        # Model ile yemek tahmin edilir
        results = predict_food(photo_bytes)
        if results["confidence"] >= 0.7:
            return jsonify({
                "label": results["label"],
                "confidence": results["confidence"]
            })
        else:
            return jsonify({"error": "Ne yazık ki yemeği tanımlayamadık."})
    except Exception as e:
        return f"Yemek tanımlanırken hata: {str(e)}" 
    
if __name__ == '__main__':
    app.run(debug=True)

