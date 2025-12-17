// DailyIntakeFoods tablosunu temsil eder (tüketilen yemek detayı)
class DailyIntakeFood {
  final int? id;
  final int intakeListId; 
  final String eatenFoodName;
  final double amount; // Tüketilen porsiyon sayısı
  final String eatenPortionDescription; 
  final double eatenCalorie; 
  final double eatenProtein;
  final double eatenFat;
  final double eatenCarb;
  final double eatenFiber;
  final double eatenSugar;
  final int? originalFoodId; // Foods.id (NULL olabilir)

  DailyIntakeFood({
    this.id,
    required this.intakeListId,
    required this.eatenFoodName,
    required this.amount,
    required this.eatenPortionDescription,
    required this.eatenCalorie,
    required this.eatenProtein,
    required this.eatenFat,
    required this.eatenCarb,
    required this.eatenFiber,
    required this.eatenSugar,
    this.originalFoodId,
  });

  factory DailyIntakeFood.fromMap(Map<String, dynamic> map) {
    return DailyIntakeFood(
      id: map['id'],
      intakeListId: map['intake_list_id'],
      eatenFoodName: map['eaten_food_name'],
      amount: map['amount'] as double,
      eatenPortionDescription: map['eaten_portion_description'],
      eatenCalorie: map['eaten_calorie'] as double,
      eatenProtein: map['eaten_protein'] as double,
      eatenFat: map['eaten_fat'] as double,
      eatenCarb: map['eaten_carb'] as double,
      eatenFiber: map['eaten_fiber'] as double,
      eatenSugar: map['eaten_sugar'] as double,
      originalFoodId: map['original_food_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'intake_list_id': intakeListId,
      'eaten_food_name': eatenFoodName,
      'amount': amount,
      'eaten_portion_description': eatenPortionDescription,
      'eaten_calorie': eatenCalorie,
      'eaten_protein': eatenProtein,
      'eaten_fat': eatenFat,
      'eaten_carb': eatenCarb,
      'eaten_fiber': eatenFiber,
      'eaten_sugar': eatenSugar,
      'original_food_id': originalFoodId,
    };
  }
}