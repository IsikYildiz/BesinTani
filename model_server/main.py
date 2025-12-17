from flask import Flask, request, jsonify
from model import predict_food
app = Flask(__name__)

# Yemek tahmin eder
@app.route('/', methods=["POST"])
def predict():
    # Gelen fotoğrafı byte haline getir
    if 'image' not in request.files:
        return jsonify({"error": "Resim dosyası gönderilmedi"}), 400

    photo_file = request.files['image']
    photo_bytes = photo_file.read()

    try:
        # Model ile yemek tahmin edilir
        results = predict_food(photo_bytes)
        if results["confidence"] >= 0.5:
            return jsonify({
                "label": results["label"],
                "confidence": results["confidence"]
            })
        else:
            return jsonify({"error": "Ne yazık ki yemeği tanımlayamadık."})
    except Exception as e:
        return f"Yemek tanımlanırken hata: {str(e)}" 
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

