import 'package:flutter/material.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/data/sample_recipes.dart';

class RecipeSearchScreen extends StatelessWidget {
  final List<String> appliances;
  final List<String> ingredients;

  const RecipeSearchScreen({
    super.key,
    required this.appliances,
    required this.ingredients,
  });

  Color _tierColor(MatchTier tier) {
    switch (tier) {
      case MatchTier.green:
        return Colors.green;
      case MatchTier.yellow:
        return Colors.orange;
      case MatchTier.red:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: hard filter — exclude recipes missing a required appliance.
    final availableRecipes = sampleRecipes
        .where((r) => r.hasRequiredAppliances(appliances))
        .toList();

    // Step 2: sort remaining recipes by ingredient match tier.
    availableRecipes.sort((a, b) =>
        a.matchTier(ingredients).index.compareTo(b.matchTier(ingredients).index));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Find Recipes'),
        backgroundColor: const Color(0xFFE85D26),
        foregroundColor: Colors.white,
      ),
      body: availableRecipes.isEmpty
          ? const Center(
              child: Text('No recipes match your appliances yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableRecipes.length,
              itemBuilder: (context, index) {
                final recipe = availableRecipes[index];
                final tier = recipe.matchTier(ingredients);
                final missing = recipe.missingIngredients(ingredients);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _tierColor(tier),
                    ),
                    title: Text(recipe.name),
                    subtitle: Text(
                      missing.isEmpty
                          ? 'You have everything! (${recipe.timeMinutes} min)'
                          : 'Missing: ${missing.join(', ')}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}