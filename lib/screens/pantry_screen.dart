import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/search_results_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

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

  @override
  void dispose() {
    ingredientController.dispose();
    super.dispose();
  }

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
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('My Pantry'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE85D26),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (appState.appliances.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Appliances: ${appState.appliances.join(', ')}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFFE85D26)),
                    ),
                  ),
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
                    fillColor: Colors.white,
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
                    final alreadyAdded = appState.pantryIngredients.contains(item);
                    return GestureDetector(
                      onTap: () {
                        if (!alreadyAdded) {
                          appState.addIngredient(item);
                        }
                        ingredientController.clear();
                        setState(() => searchResults = []);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: alreadyAdded
                              ? const Color(0xFFE85D26).withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: alreadyAdded ? Colors.grey.shade300 : const Color(0xFFE85D26),
                          ),
                        ),
                        child: Text(
                          alreadyAdded ? '✓ $item' : item,
                          style: TextStyle(
                            color: alreadyAdded ? Colors.grey : const Color(0xFFE85D26),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (appState.pantryIngredients.isEmpty)
                  Text(
                    'No ingredients added yet',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  )
                else ...[
                  const Text(
                    'Your Pantry:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: appState.pantryIngredients.map((item) {
                      return Chip(
                        label: Text(item, style: const TextStyle(fontSize: 13)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => appState.removeIngredient(item),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchResultsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D26),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Find Recipes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}