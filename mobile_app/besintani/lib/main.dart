import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'repositories/food_repository.dart';      
import 'repositories/intake_repository.dart';    
import 'repositories/server_repository.dart';    
import 'viewmodels/intake_viewmodel.dart';      
import 'screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Widget'ların başlatılması
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  
  // Veritabanı başlatma 
  await DatabaseHelper.instance.database;

  // Repository'lerin örneklerini oluşturma
  final foodRepo = FoodRepository();
  final intakeRepo = IntakeRepository();
  final serverRepo = ServerRepository();
  
  runApp(
    MultiProvider(
      // Tüm uygulama katmanlarına erişimi sağlayan Provider'lar
      providers: [
        // Repository'ler 
        Provider(create: (context) => foodRepo),
        Provider(create: (context) => intakeRepo),
        Provider(create: (context) => serverRepo),
        
        // View Model 
        ChangeNotifierProvider(
          create: (context) => IntakeViewModel(intakeRepo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Tracker',
      supportedLocales: const [
        Locale('en', 'US'), 
        Locale('tr', 'TR'), 
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('tr', 'TR'),
      theme: ThemeData(
        // Uygulama genel teması
        primarySwatch: Colors.deepOrange, 
        scaffoldBackgroundColor: const Color(0xFF4B2E83), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4B2E83), 
          elevation: 0,
        ),
      ),
      // İlk ekran 
      home: const MainScreen(), 
    );
  }
}