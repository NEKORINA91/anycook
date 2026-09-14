import 'package:flutter/material.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/screens/recipe_detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const RecipeCard({
    super.key, 
    required this.recipe,
    this.width = 140,
    this.margin = const EdgeInsets.only(right: 12),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        width: width,
        margin: margin,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 32))),
            ),
            const SizedBox(height: 8),
            Text(
              recipe.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${recipe.timeMinutes} min',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}