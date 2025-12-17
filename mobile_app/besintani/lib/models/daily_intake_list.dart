// DailyIntakeList tablosunu temsil eder (günlük özet)
class DailyIntakeList {
  final int? id;
  final String date; // YYYY-MM-DD formatında
  final double totalCalorie;
  final double totalProtein;
  final double totalFat;
  final double totalCarb;
  final double totalFiber;
  final double totalSugar;

  DailyIntakeList({
    this.id,
    required this.date,
    this.totalCalorie = 0.0,
    this.totalProtein = 0.0,
    this.totalFat = 0.0,
    this.totalCarb = 0.0,
    this.totalFiber = 0.0,
    this.totalSugar = 0.0,
  });

  factory DailyIntakeList.fromMap(Map<String, dynamic> map) {
    return DailyIntakeList(
      id: map['id'],
      date: map['date'],
      totalCalorie: map['total_calorie'] as double,
      totalProtein: map['total_protein'] as double,
      totalFat: map['total_fat'] as double,
      totalCarb: map['total_carb'] as double,
      totalFiber: map['total_fiber'] as double,
      totalSugar: map['total_sugar'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'total_calorie': totalCalorie,
      'total_protein': totalProtein,
      'total_fat': totalFat,
      'total_carb': totalCarb,
      'total_fiber': totalFiber,
      'total_sugar': totalSugar,
    };
  }
}