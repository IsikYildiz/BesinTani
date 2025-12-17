import 'package:flutter/material.dart';
import '../repositories/intake_repository.dart';
import '../models/daily_intake_list.dart';
import '../models/daily_intake_food.dart';

class IntakeViewModel extends ChangeNotifier {
  final IntakeRepository _intakeRepo;
  
  // Takip edilen değişkenler
  DailyIntakeList? _currentIntakeList;
  List<DailyIntakeFood> _eatenFoods = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false; // Yükleme durumu

  // Getter metotları
  DailyIntakeList? get currentIntakeList => _currentIntakeList;
  List<DailyIntakeFood> get eatenFoods => _eatenFoods;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  // Kurucu Repository'yi alır
  IntakeViewModel(this._intakeRepo) {
    // Uygulama başladığında bugünün verisini yükler
    loadDailyIntake(DateTime.now());
  }

  // Seçilen tarihi değiştiren fonksiyon 
  void selectDate(DateTime newDate) {
    if (_selectedDate.day != newDate.day || _selectedDate.month != newDate.month || _selectedDate.year != newDate.year) {
      _selectedDate = newDate;
      loadDailyIntake(newDate);
    }
  }
  
  // Seçilen tarihin verisini yükleme
  Future<void> loadDailyIntake(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Tarihi "YYYY-MM-DD" formatına çevirir
      final dateString = date.toIso8601String().substring(0, 10);
      
      // Repository'den listeyi ve yemekleri çeker
      _currentIntakeList = await _intakeRepo.getOrCreateDailyIntakeList(dateString);
      _eatenFoods = await _intakeRepo.getFoodsForDate(dateString);

    } catch (e) {
      print('Intake verisi yüklenirken hata: $e');
      _currentIntakeList = null; 
      _eatenFoods = [];
    }

    _isLoading = false;
    notifyListeners(); // UI'ın güncellenmesini tetikler
  }

  // Yemek ekleme işlemi 
  Future<void> addFood(DailyIntakeFood food) async {
    _isLoading = true;
    notifyListeners();

    await _intakeRepo.addFoodToDailyIntake(food);
    
    // Veriler değiştiği için listeyi yeniden yükleme
    await loadDailyIntake(_selectedDate); 
  }

  // Yemek silme işlemi
  Future<void> removeFood(int foodId, int intakeListId) async {
    _isLoading = true;
    notifyListeners();

    await _intakeRepo.removeFoodFromDailyIntake(foodId, intakeListId);
    
    // Veriler değiştiği için listeyi yeniden yükleme
    await loadDailyIntake(_selectedDate);
  }
}