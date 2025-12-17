// Foods tablosunu temsil eder
class Food {
  final int? id;
  final String name;
  final double defaultPortionCalorie;
  final String defaultPortionType;
  final double defaultPortionGrams; 
  final double proteinPer100g;
  final double fatPer100g;
  final double carbPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final String simpleRecipe;
  final String specialComment;

  Food({
    this.id,
    required this.name,
    required this.defaultPortionCalorie,
    required this.defaultPortionType,
    required this.defaultPortionGrams,
    required this.proteinPer100g,
    required this.fatPer100g,
    required this.carbPer100g,
    required this.fiberPer100g,
    required this.sugarPer100g,
    required this.simpleRecipe,
    required this.specialComment,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      defaultPortionCalorie: map['default_portion_calorie'] as double,
      defaultPortionType: map['default_portion_type'],
      defaultPortionGrams: map['default_portion_grams'] as double,
      proteinPer100g: map['protein_per_100g'] as double,
      fatPer100g: map['fat_per_100g'] as double,
      carbPer100g: map['carb_per_100g'] as double,
      fiberPer100g: map['fiber_per_100g'] as double,
      sugarPer100g: map['sugar_per_100g'] as double,
      simpleRecipe: map['simple_recipe'] ?? '',
      specialComment: map['special_comment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'default_portion_calorie': defaultPortionCalorie,
      'default_portion_type': defaultPortionType,
      'default_portion_grams': defaultPortionGrams,
      'protein_per_100g': proteinPer100g,
      'fat_per_100g': fatPer100g,
      'carb_per_100g': carbPer100g,
      'fiber_per_100g': fiberPer100g,
      'sugar_per_100g': sugarPer100g,
      'simple_recipe': simpleRecipe,
      'special_comment': specialComment,
    };
  }
}