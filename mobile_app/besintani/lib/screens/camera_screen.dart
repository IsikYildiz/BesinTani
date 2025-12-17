import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../repositories/server_repository.dart';
import 'food_page.dart'; 

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isPredicting = false;
  String _predictionResult = "Bir fotoğraf çekin veya galeriden seçin.";

  // Görüntü seçme ve izin kontrolü 
  Future<void> _pickImage(ImageSource source) async {
    // Kamera izni kontrolü 
    if (source == ImageSource.camera && await Permission.camera.request().isDenied) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _predictionResult = "Görüntü sunucuya gönderiliyor...";
          _isPredicting = true;
        });
        
        // Tahmin işlemini başlatma
        _runPrediction(_imageFile!);
      }
    } catch (e) {
      setState(() {
        _predictionResult = "Hata: Görüntü seçilemedi.";
        _isPredicting = false;
      });
    }
  }

  // Tahmin işlemini ServerRepository'ye gönderme
  Future<void> _runPrediction(File image) async {
    final serverRepo = Provider.of<ServerRepository>(context, listen: false);
    
    // Server'dan tahmin sonucunu al: {'food_name': 'Yemek Adı', 'confidence': 0.95} veya null
    final Map<String, dynamic>? result = await serverRepo.predictFood(image);

    setState(() {
      _isPredicting = false;
      if (result != null) {
        final String foodName = result['food_name'];
        final double confidence = result['confidence'] as double;
        
        // Sunucu tarafından gelen tahmin
        _predictionResult = "$foodName (Güven: %${(confidence * 100).toStringAsFixed(1)})";
        
        // Yemek detay sayfasına yönlendirme
        _navigateToFoodPage(foodName);

      } else {
        // Sunucu ya hata verdi ya da güvenilirlik düşük olduğu için NULL döndürdü.
        _predictionResult = "Tanıma Başarısız: Lütfen daha net bir fotoğraf çekin veya arama yapın.";
      }
    });
  }

  // Kamera/Galeri izinleri reddedilirse uyarı gösterme
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İzin Gerekli'),
        content: const Text(
            'Kamera ve Galeri özelliklerini kullanabilmek için bu izinlere ihtiyacımız var. Lütfen ayarlar üzerinden uygulamaya izin verin.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); 
            },
            child: const Text('Ayarlara Git'),
          ),
        ],
      ),
    );
  }

  // Tahmin başarılı olduğunda yemek detay sayfasına geçiş 
  void _navigateToFoodPage(String foodName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Yemek detay sayfasına yemek ismi gönderme
        builder: (context) => FoodPage(foodName: foodName), 
      ),
    ).then((_) {
      setState(() {
        _imageFile = null;
        _predictionResult = "Yeni bir fotoğraf çekin veya seçin.";
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    // Ana kamera ekranı 
    return Stack(
      children: [
        
        if (_imageFile != null)
          Positioned.fill(
            child: Image.file(_imageFile!, fit: BoxFit.cover),
          )
        else
          Container(color: Colors.deepPurple), 

        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isPredicting)
                const CircularProgressIndicator(color: Colors.deepOrange),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _predictionResult,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isPredicting ? Colors.white : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Kamera butonu
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: IconButton(
              iconSize: 80,
              icon: Icon(
                Icons.camera_alt,
                color: Colors.white,
                shadows: [BoxShadow(color: Colors.black, blurRadius: 4.0)],
              ),
              onPressed: _isPredicting ? null : () => _pickImage(ImageSource.camera), 
            ),
          ),
        ),

        // Galeri butonu
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(Icons.photo_library, size: 30, color: Colors.white),
            onPressed: _isPredicting ? null : () => _pickImage(ImageSource.gallery), 
          ),
        ),
      ],
    );
  }
}