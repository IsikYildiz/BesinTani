import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/food.dart';

class DatabaseHelper {
  static final _databaseName = "FoodTrackerDB.db";
  static final _databaseVersion = 1;
  
  // Tablo isimleri
  static const String tableFoods = 'Foods';
  static const String tableIntakeList = 'DailyIntakeList';
  static const String tableIntakeFoods = 'DailyIntakeFoods';

  // Singleton sınıf yapısı
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String documentsDirectory = await getDatabasesPath();
    String path = join(documentsDirectory, _databaseName);
    // Veritabanı ilk kez açıldığında _onCreate çağrılır
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // Tabloları oluşturur ve Seeding yapar
  Future _onCreate(Database db, int version) async {
    // Foods tablosu 
    await db.execute('''
      CREATE TABLE $tableFoods (
        id INTEGER PRIMARY KEY, 
        name TEXT NOT NULL, 
        default_portion_calorie REAL,
        default_portion_type TEXT,
        default_portion_grams REAL,
        protein_per_100g REAL,
        fat_per_100g REAL,
        carb_per_100g REAL,
        fiber_per_100g REAL,
        sugar_per_100g REAL,
        simple_recipe TEXT,
        special_comment TEXT
      )
    ''');
    
    // DailyIntakeList tablosu 
    await db.execute('''
      CREATE TABLE $tableIntakeList (
        id INTEGER PRIMARY KEY, 
        date TEXT NOT NULL UNIQUE, 
        total_calorie REAL DEFAULT 0.0, 
        total_protein REAL DEFAULT 0.0, 
        total_fat REAL DEFAULT 0.0, 
        total_carb REAL DEFAULT 0.0,
        total_fiber REAL DEFAULT 0.0, 
        total_sugar REAL DEFAULT 0.0
      )
    ''');

    // DailyIntakeFoods tablosu 
    await db.execute('''
      CREATE TABLE $tableIntakeFoods (
        id INTEGER PRIMARY KEY, 
        intake_list_id INTEGER NOT NULL,
        eaten_food_name TEXT NOT NULL,
        amount REAL NOT NULL, 
        eaten_portion_description TEXT,
        eaten_calorie REAL NOT NULL,
        eaten_protein REAL,
        eaten_fat REAL,
        eaten_carb REAL,
        eaten_fiber REAL,
        eaten_sugar REAL,
        original_food_id INTEGER,
        FOREIGN KEY (intake_list_id) REFERENCES $tableIntakeList(id) ON DELETE CASCADE,
        FOREIGN KEY (original_food_id) REFERENCES $tableFoods(id)
      )
    ''');

    // Başlangıç verisi ekleme (yemek verileri)
    await _insertInitialFoodData(db);
  }

  // JSON'dan veri okuma ve ekleme metodu
  Future<void> _insertInitialFoodData(Database db) async {
    try {
      // foods_data.json dosyasını oku
      final String jsonString = await rootBundle.loadString('lib/assets/foods_data.json');
      final List<dynamic> foodsList = json.decode(jsonString);

      for (var foodMap in foodsList) {
        // Map'i Food modeline dönüştürerek tip güvenliğini kontrol et
        final food = Food.fromMap(foodMap as Map<String, dynamic>);
        
        // Veritabanına ekle
        await db.insert(
          tableFoods, 
          food.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace
        );
      }
      print('${foodsList.length} adet yemek bilgisi veritabanına başarıyla eklendi.');
    } catch (e) {
      print('Hata: Başlangıç verisi yüklenirken sorun oluştu: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllFoods() async {
    final db = await database;
    return await db.query(tableFoods);
  }
}