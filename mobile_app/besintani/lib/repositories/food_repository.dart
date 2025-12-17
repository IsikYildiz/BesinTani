import '../database/database_helper.dart';
import '../models/food.dart';

class FoodRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Sorguya göre arama yapar
  Future<List<Food>> searchFood(String query) async {
    // Arama teriminin temizlenmesi
    final cleanQuery = query.trim();

    if (cleanQuery.isEmpty) {
      return [];
    }
    
    final db = await _dbHelper.database;
    // Arama
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableFoods,
      where: 'name LIKE ? COLLATE NOCASE',
      whereArgs: ['%$cleanQuery%'],
      orderBy: 'name ASC',
      limit: 5,
    );
    
    // Map listesini Food model listesine dönüştürür
    return List.generate(maps.length, (i) {
      return Food.fromMap(maps[i]);
    });
  }

  // Belirli bir yemeğin bilgilerini ID ile getirir
  Future<Food?> getFoodById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableFoods,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }
    return Food.fromMap(maps.first);
  }

  // Model tahmininden gelen isme göre yemeği getirir
  Future<Food?> getFoodByName(String name) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableFoods,
      where: 'name = ? COLLATE NOCASE', 
      whereArgs: [name.trim()],
    );

    if (maps.isEmpty) {
      return null;
    }
    return Food.fromMap(maps.first);
  }
}