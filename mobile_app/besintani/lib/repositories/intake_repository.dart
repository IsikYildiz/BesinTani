import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/daily_intake_list.dart';
import '../models/daily_intake_food.dart';

class IntakeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Belirli bir tarihe ait DailyIntakeList kaydını bulur veya yoksa oluşturur.
  Future<DailyIntakeList> getOrCreateDailyIntakeList(String date) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableIntakeList,
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return DailyIntakeList.fromMap(maps.first);
    } else {
      // Bulunamazsa yeni bir kayıt oluşturur
      final newList = DailyIntakeList(date: date);
      final id = await db.insert(
        DatabaseHelper.tableIntakeList, 
        newList.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // Oluşturulan kaydı ID ile geri döndürür
      return DailyIntakeList(
        id: id,
        date: date,
      );
    }
  }

  // Belirli bir tarihe ait tüketilen tüm yemekleri getirir
  Future<List<DailyIntakeFood>> getFoodsForDate(String date) async {
    final DailyIntakeList list = await getOrCreateDailyIntakeList(date);

    if (list.id == null) return []; 

    final db = await _dbHelper.database;
    // Sorgulama
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableIntakeFoods,
      where: 'intake_list_id = ?',
      whereArgs: [list.id],
      orderBy: 'id DESC', 
    );

    return List.generate(maps.length, (i) {
      return DailyIntakeFood.fromMap(maps[i]);
    });
  }

  Future<void> addFoodToDailyIntake(DailyIntakeFood food) async {
    final db = await _dbHelper.database;
    
    // Transaction 
    await db.transaction((txn) async {
      // DailyIntakeFoods tablosuna yeni yemeği ekleme
      await txn.insert(
        DatabaseHelper.tableIntakeFoods,
        food.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // DailyIntakeList özetini güncelleme
      await _updateDailyTotals(txn, food.intakeListId);
    });
  }

  Future<void> removeFoodFromDailyIntake(int foodId, int intakeListId) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // DailyIntakeFoods tablosundan yemeği silme
      await txn.delete(
        DatabaseHelper.tableIntakeFoods,
        where: 'id = ?',
        whereArgs: [foodId],
      );

      // DailyIntakeList özetini güncelleme
      await _updateDailyTotals(txn, intakeListId);
    });
  }

  Future<void> _updateDailyTotals(Transaction txn, int intakeListId) async {
    // İlgili güne ait tüm yemeklerin toplam değerlerini hesaplama
    final List<Map<String, dynamic>> result = await txn.rawQuery('''
      SELECT 
        SUM(eaten_calorie) as total_calorie,
        SUM(eaten_protein) as total_protein,
        SUM(eaten_fat) as total_fat,
        SUM(eaten_carb) as total_carb,
        SUM(eaten_fiber) as total_fiber,
        SUM(eaten_sugar) as total_sugar
      FROM ${DatabaseHelper.tableIntakeFoods}
      WHERE intake_list_id = ?
    ''', [intakeListId]);

    final totals = result.first;
    
    // DailyIntakeList kaydını güncelleme
    await txn.update(
      DatabaseHelper.tableIntakeList,
      {
        'total_calorie': totals['total_calorie'] ?? 0.0,
        'total_protein': totals['total_protein'] ?? 0.0,
        'total_fat': totals['total_fat'] ?? 0.0,
        'total_carb': totals['total_carb'] ?? 0.0,
        'total_fiber': totals['total_fiber'] ?? 0.0,
        'total_sugar': totals['total_sugar'] ?? 0.0,
      },
      where: 'id = ?',
      whereArgs: [intakeListId],
    );
  }

  // Belirli bir zaman aralığındaki toplam tüketimi hesaplar
  Future<Map<String, double>> getTotalsByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        SUM(total_calorie) as total_calorie,
        SUM(total_protein) as total_protein,
        SUM(total_fat) as total_fat,
        SUM(total_carb) as total_carb
      FROM ${DatabaseHelper.tableIntakeList}
      WHERE date BETWEEN ? AND ?
    ''', [startDate, endDate]);

    final totals = result.first;

    // Veri yoksa veya null ise 0.0 döndürür
    return {
      'calorie': (totals['total_calorie'] as num?)?.toDouble() ?? 0.0,
      'protein': (totals['total_protein'] as num?)?.toDouble() ?? 0.0,
      'fat': (totals['total_fat'] as num?)?.toDouble() ?? 0.0,
      'carb': (totals['total_carb'] as num?)?.toDouble() ?? 0.0,
      };
    }

  Future<List<DailyIntakeList>> getDailyIntakeRecords(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableIntakeList,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => DailyIntakeList.fromMap(maps[i]));
  }
}