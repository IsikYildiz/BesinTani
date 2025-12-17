import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'search_screen.dart';       
import 'intake_list_screen.dart';  
import 'statistics_screen.dart';   

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 
  
  final List<Widget> _screens = const [
    CameraScreen(),       // Kamera/Tanıma 
    SearchScreen(),       // Arama 
    IntakeListScreen(),   // Günlüğüm 
    StatisticsScreen(),   // İstatistik 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Ekranın adına göre başlık değişebilir
        title: Text(_getAppBarTitle(_selectedIndex)), 
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Koyu mor arka plan
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Tanıma',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Arama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Günlüğüm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'İstatistik',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange, 
        unselectedItemColor: Colors.white70, 
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Koyu mor arka plan
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
      ),
    );
  }
  
  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'Yemek Tanıma';
      case 1: return 'Yemek Arama';
      case 2: return 'Günlük Tüketim';
      case 3: return 'İstatistikler';
      default: return 'Food Tracker';
    }
  }
}