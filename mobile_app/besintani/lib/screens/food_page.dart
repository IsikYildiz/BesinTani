import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../repositories/food_repository.dart';
import '../models/daily_intake_food.dart'; 
import '../viewmodels/intake_viewmodel.dart'; 

class FoodPage extends StatefulWidget {
  final String foodName;
  
  // Arama ekranından veya kamera ekranından gelen yemek ismi
  const FoodPage({super.key, required this.foodName});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  Food? _food;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFoodDetails();
  }

  // FoodRepository'yi kullanarak DB'den yemeğin detaylarını çeker
  Future<void> _loadFoodDetails() async {
    try {
      final foodRepo = Provider.of<FoodRepository>(context, listen: false);
      
      final food = await foodRepo.getFoodByName(widget.foodName);

      setState(() {
        _food = food;
        _isLoading = false;
        if (food == null) {
          _error = 'Yemek veritabanında bulunamadı.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Veri yüklenirken hata oluştu: $e';
      });
    }
  }

  // Günlüğe ekleme
  void _showAddToIntakeDialog(Food food) {
    // Varsayılan porsiyon sayısı
    double portionAmount = 1.0; 
    final TextEditingController _gramController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            
            // Hesaplanan toplam kalori
            final totalCalorie = food.defaultPortionCalorie * portionAmount;
            
            return AlertDialog(
              title: Text('${food.name} Günlüğe Ekle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _gramController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Miktar (Gram)',
                      hintText: 'Örn: 250',
                      suffixText: 'g',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setStateInDialog(() {
                        double? enteredGram = double.tryParse(val);
                        if (enteredGram != null && enteredGram > 0) {
                          portionAmount = enteredGram / food.defaultPortionGrams;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text('Veya Porsiyon Seçin:', style: TextStyle(fontSize: 12)),
                  
                  // Porsiyon miktarını değiştiren alan 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setStateInDialog(() {
                            if (portionAmount > 0.1) portionAmount -= 0.5;
                            _gramController.text = (portionAmount * food.defaultPortionGrams).toStringAsFixed(0);
                          });
                        },
                      ),
                      Text('${portionAmount.toStringAsFixed(1)} Porsiyon'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setStateInDialog(() {
                            portionAmount += 0.5;
                            _gramController.text = (portionAmount * food.defaultPortionGrams).toStringAsFixed(0);
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(
                    'Tahmini Toplam Kalori: ${totalCalorie.toStringAsFixed(0)} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Ekle'),
                  onPressed: () {
                    if (portionAmount > 0) {
                      _addFoodToDailyIntake(food, portionAmount);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // IntakeViewModel'i çağırarak veritabanına kaydı yapan metot
  void _addFoodToDailyIntake(Food food, double amount) async {
    final viewModel = Provider.of<IntakeViewModel>(context, listen: false);
    
    final intakeListId = viewModel.currentIntakeList?.id;

    if (intakeListId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hata: Günlük liste başlatılamadı.')),
      );
      return;
    }

    // Makro besin hesaplamaları 
    final double totalGrams = food.defaultPortionGrams * amount;
    
    final calculateMacro = (double per100g) => (per100g / 100.0) * totalGrams;

    final newIntake = DailyIntakeFood(
      intakeListId: intakeListId,
      eatenFoodName: food.name,
      amount: amount,
      eatenPortionDescription: '${amount.toStringAsFixed(1)} ${food.defaultPortionType}',
      eatenCalorie: food.defaultPortionCalorie * amount,
      eatenProtein: calculateMacro(food.proteinPer100g),
      eatenFat: calculateMacro(food.fatPer100g),
      eatenCarb: calculateMacro(food.carbPer100g),
      eatenFiber: calculateMacro(food.fiberPer100g),
      eatenSugar: calculateMacro(food.sugarPer100g),
      originalFoodId: food.id,
    );

    await viewModel.addFood(newIntake);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} günlüğe eklendi.')),
    );
    
    // Yemek eklendikten sonra FoodPage'i kapatıp önceki ekrana döner
    Navigator.of(context).pop(); 
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Yükleniyor...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error.isNotEmpty || _food == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(child: Text(_error.isNotEmpty ? _error : "Yemek bulunamadı: ${widget.foodName}")),
      );
    }
    
    final food = _food!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(food.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yemek fotoğrafı
            _buildFoodImage(food.name),
            const SizedBox(height: 20),

            // Kalori bilgi kutusu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade400, 
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${food.defaultPortionType} (${food.defaultPortionGrams.toStringAsFixed(0)}g): ${food.defaultPortionCalorie.toStringAsFixed(0)} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Besin tablosu
            const Text('Besin Değerleri (100g Başına):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            _buildNutritionTable(food),
            const SizedBox(height: 20),

            // Tarif
            const SizedBox(height: 20),
            const Text('Hazırlanışı:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            
            Card(
              color: Colors.white.withOpacity(0.4), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...food.simpleRecipe
                    .replaceAll(RegExp(r'\d+[\.)]\s*'), '') // "1." veya "1)" gibi sayıları siler
                    .split('.')
                    .where((s) => s.trim().length > 3) // Kısa parçaları (boşluk gibi) atlar
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${entry.key + 1}. ", 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                            Expanded(
                              child: Text(
                                entry.value.trim(), 
                                style: const TextStyle(color: Colors.white, height: 1.4)
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Özel yorum
            if (food.specialComment.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Not:', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Card(
                color: Colors.amber.shade100.withOpacity(0.9), // Yorum olduğu için dikkat çekici bir renk
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          food.specialComment,
                          style: const TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Günlüğe ekleme butonu
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showAddToIntakeDialog(food), // UC6: Dialog açılır
                icon: const Icon(Icons.add),
                label: const Text('Günlüğe Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
  
  Widget _buildNutritionTable(Food food) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade400),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: [
        _buildTableRow('Protein', '${food.proteinPer100g.toStringAsFixed(1)} g'),
        _buildTableRow('Yağ', '${food.fatPer100g.toStringAsFixed(1)} g'),
        _buildTableRow('Karbonhidrat', '${food.carbPer100g.toStringAsFixed(1)} g'),
        _buildTableRow('Lif', '${food.fiberPer100g.toStringAsFixed(1)} g'),
        _buildTableRow('Şeker', '${food.sugarPer100g.toStringAsFixed(1)} g'),
        _buildTableRow('Kalori', 
                        '${((food.proteinPer100g * 4) + (food.fatPer100g * 9) + (food.carbPer100g * 4)).toStringAsFixed(0)} kcal', 
                        isHeader: true),
      ],
    );
  }

  Widget _buildFoodImage(String foodName) {
    String imagePath = 'lib/assets/food_images/$foodName.jpg';

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          imagePath,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          // Dosya bulunamazsa default ikon
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade800,
              child: const Icon(Icons.fastfood, size: 80, color: Colors.white54),
            );
          },
        ),
      ),
    );
  }
  
  TableRow _buildTableRow(String label, String value, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(color: isHeader ? Colors.deepPurple.shade50 : Colors.white),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(label, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(value, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        ),
      ],
    );
  }
}