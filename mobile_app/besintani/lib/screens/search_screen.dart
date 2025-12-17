import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/food_repository.dart';
import '../models/food.dart';
import 'food_page.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Food> _searchResults = [];
  bool _isLoading = false;
  
  // Arama metni değiştikçe bu metot çağrılır
  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    
    _performSearch(query);
  }

  // Veritabanı arama işlemini FoodRepository ile gerçekleştirir 
  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final foodRepo = Provider.of<FoodRepository>(context, listen: false);
      final results = await foodRepo.searchFood(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
        // Hata durumunu kullanıcıya gösterir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama sırasında bir hata oluştu: $e')),
        );
      });
    }
  }
  
  // Arama sonucuna tıklandığında detay sayfasına yönlendirme
  void _navigateToFoodPage(String foodName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FoodPage(foodName: foodName), 
      ),
    );
    FocusScope.of(context).unfocus();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Yemek Ara (Örn: İskender, Mercimek Çorbası)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: Colors.grey.shade200, 
            ),
          ),
        ),

        if (_isLoading)
          const LinearProgressIndicator(color: Colors.deepOrange)
        else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text('Aradığınız kritere uygun yemek bulunamadı.'),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final food = _searchResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.white.withOpacity(0.8), // Hafif belirgin arka plan
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant, color: Colors.deepOrange),
                    title: Text(
                      food.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    subtitle: Text(
                      '${food.defaultPortionType}: ${food.defaultPortionCalorie.toStringAsFixed(0)} kcal',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    onTap: () => _navigateToFoodPage(food.name),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}