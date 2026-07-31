import 'package:flutter/material.dart';

class RecipeSearchScreen extends StatelessWidget {
  final List<String> appliances;
  final List<String> ingredients;

  const RecipeSearchScreen({
    super.key,
    required this.appliances,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Find Recipes'),
        backgroundColor: const Color(0xFFE85D26),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appliances: ${appliances.join(', ')}'),
            const SizedBox(height: 8),
            Text('Ingredients: ${ingredients.join(', ')}'),
          ],
        ),
      ),
    );
  }
}