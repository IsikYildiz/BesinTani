import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../viewmodels/intake_viewmodel.dart';
import '../models/daily_intake_food.dart';

class IntakeListScreen extends StatelessWidget {
  const IntakeListScreen({super.key});

  // Takvim açma ve tarih değiştirme işlevi 
  Future<void> _selectDate(BuildContext context, IntakeViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2023), // Uygulamanın başlangıç tarihi
      lastDate: DateTime.now(),   // Bugünün tarihi
      locale: const Locale('tr', 'TR'), 
    );

    if (picked != null) {
      viewModel.selectDate(picked);
    }
  }

  // Yemek silme işlevi 
  void _removeFood(BuildContext context, IntakeViewModel viewModel, DailyIntakeFood food) {
    if (food.id != null && viewModel.currentIntakeList?.id != null) {
      viewModel.removeFood(food.id!, viewModel.currentIntakeList!.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yemek listeden çıkarıldı.'), duration: Duration(seconds: 1)),
      );
    }
  }

  void _showManualAddDialog(BuildContext context, IntakeViewModel viewModel) {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    final fatController = TextEditingController();
    final carbController = TextEditingController();
    final gramController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manuel Yemek Ekle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Yemek Adı')),
              TextField(controller: gramController, decoration: const InputDecoration(labelText: 'Miktar (Gram)'), keyboardType: TextInputType.number),
              TextField(controller: calController, decoration: const InputDecoration(labelText: 'Kalori (kcal)'), keyboardType: TextInputType.number),
              TextField(controller: proteinController, decoration: const InputDecoration(labelText: 'Protein (g)'), keyboardType: TextInputType.number),
              TextField(controller: fatController, decoration: const InputDecoration(labelText: 'Yağ (g)'), keyboardType: TextInputType.number),
              TextField(controller: carbController, decoration: const InputDecoration(labelText: 'Karbonhidrat (g)'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              if (viewModel.currentIntakeList?.id != null) {
                final manualFood = DailyIntakeFood(
                  intakeListId: viewModel.currentIntakeList!.id!,
                  eatenFoodName: nameController.text,
                  amount: 1.0, 
                  eatenPortionDescription: "${gramController.text}g Manuel Giriş",
                  eatenCalorie: double.tryParse(calController.text) ?? 0,
                  eatenProtein: double.tryParse(proteinController.text) ?? 0,
                  eatenFat: double.tryParse(fatController.text) ?? 0,
                  eatenCarb: double.tryParse(carbController.text) ?? 0,
                  eatenFiber: 0,
                  eatenSugar: 0,
                );
                viewModel.addFood(manualFood);
                Navigator.pop(context);
              }
            },
          child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B2E83), 
      
      body: Consumer<IntakeViewModel>(
        builder: (context, viewModel, child) {
          final formattedDate = DateFormat('dd/MM/yyyy').format(viewModel.selectedDate);
          final intakeList = viewModel.currentIntakeList;
        
          return Column(
            children: [
              // Tarih seçici kutusu
              GestureDetector(
                onTap: viewModel.isLoading ? null : () => _selectDate(context, viewModel),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),

              // Günlük özet kartı (Kalori ve Makrolar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  color: Colors.deepPurple.shade700,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Toplam Kalori:', style: TextStyle(color: Colors.white70)),
                            Text(
                              '${intakeList?.totalCalorie.toStringAsFixed(0) ?? '0'} kcal',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white38),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMacroItem('Protein', intakeList?.totalProtein ?? 0),
                            _buildMacroItem('Yağ', intakeList?.totalFat ?? 0),
                            _buildMacroItem('Karb.', intakeList?.totalCarb ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Yemek listesi alanı
              if (viewModel.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Colors.white)))
              else if (viewModel.eatenFoods.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Text('Bu güne ait tüketim kaydı bulunamadı.', style: TextStyle(color: Colors.white70)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.eatenFoods.length,
                    itemBuilder: (context, index) {
                      final food = viewModel.eatenFoods[index];
                      return _buildFoodListItem(context, viewModel, food);
                    },
                  ),
                ),
            ],
          );
        },
      ),

      // Manuel ekleme
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
        onPressed: () => _showManualAddDialog(
          context, 
          Provider.of<IntakeViewModel>(context, listen: false)
        ),
      ),
    );
  }

  // Makro besin widget
  Widget _buildMacroItem(String title, double amount) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text('${amount.toStringAsFixed(1)} g', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Yemek liste widget
  Widget _buildFoodListItem(BuildContext context, IntakeViewModel viewModel, DailyIntakeFood food) {
    // Widget'ı ile sola kaydırarak silme
    return Dismissible(
      key: Key(food.id.toString()), 
      direction: DismissDirection.endToStart, // Sadece sağdan sola kaydırma
      onDismissed: (direction) {
        _removeFood(context, viewModel, food); 
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red.shade700,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: Colors.deepPurple.shade900,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            color: Colors.grey.shade600, // Eskizdeki "Food Photo" alanı
            child: const Icon(Icons.fastfood, color: Colors.white),
          ),
          title: Text(
            food.eatenFoodName, // Food Name
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(
            food.eatenPortionDescription, // Portion Eaten
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Text(
            '${food.eatenCalorie.toStringAsFixed(0)} kcal', // Calorie Info
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange),
          ),
        ),
      ),
    );
  }
}