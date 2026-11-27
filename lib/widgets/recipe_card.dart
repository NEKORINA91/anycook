import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/screens/recipe_detail_screen.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/ui.dart';

/// Recipe card from the redesign: big coloured image area with a pantry-match
/// badge, name + rating, and a meta line. Grows into the recipe page on tap.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final double imageHeight;

  const RecipeCard({super.key, required this.recipe, this.imageHeight = 180});

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<AppState>().pantryIngredients;
    final appliance = recipe.requiredAppliances.isEmpty ? 'Any kitchen' : recipe.requiredAppliances.join(', ');

    return OpenContainer(
      tappable: false, // Pressable handles the tap
      transitionDuration: const Duration(milliseconds: 450),
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedColor: AppColors.surface,
      openColor: AppColors.bg,
      middleColor: AppColors.bg,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.line),
      ),
      openBuilder: (_, _) => RecipeDetailScreen(recipe: recipe),
      closedBuilder: (context, open) => Pressable(
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FoodArt(
                seed: recipe.name,
                height: imageHeight,
                iconSize: imageHeight * 0.3,
                badge: pantry.isEmpty ? null : TierBadge(recipe: recipe, pantry: pantry),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 14, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.display(size: 19, weight: FontWeight.w500),
                          ),
                        ),
                        if (recipe.rating > 0) ...[
                          const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                          const SizedBox(width: 2),
                          Text(
                            recipe.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${recipe.timeMinutes} min · $appliance · ${recipe.creatorName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
