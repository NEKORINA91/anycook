import 'package:flutter/material.dart';
import 'package:anycook/screens/recipe_search_screen.dart';

class PantryScreen extends StatefulWidget {
  final List<String> appliances;

  const PantryScreen({
    super.key,
    required this.appliances,
  });

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final List<String> allIngredients = [
    'Flour', 'Rice', 'Eggs', 'Milk', 'Butter', 'Sugar',
    'Salt', 'Onion', 'Garlic', 'Tomato', 'Potato', 'Carrot',
    'Chicken', 'Beef', 'Fish', 'Cheese', 'Yogurt', 'Bread',
    'Pasta', 'Oil', 'Pepper', 'Ginger', 'Lemon', 'Coconut Milk',
  ];

  List<String> searchResults = [];
  final TextEditingController ingredientController = TextEditingController();
  List<String> ingredients = [];

  void updateSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = allIngredients
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Pantry'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE85D26),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.appliances.join(', '),
              style: const TextStyle(fontSize: 16, color: Color(0xFFE85D26)),
            ),
            const SizedBox(height: 30),
            const Text(
              'What ingredients do you have?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ingredientController,
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText: 'Search Ingredients...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchResults.map((item) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!ingredients.contains(item)) {
                        ingredients.add(item);
                      }
                      ingredientController.clear();
                      searchResults = [];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE85D26)),
                    ),
                    child: Text(item),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              ingredients.isEmpty
                  ? 'No ingredients added yet'
                  : 'Your Pantry: ${ingredients.join(', ')}',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeSearchScreen(
                      appliances: widget.appliances,
                      ingredients: ingredients,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D26),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}