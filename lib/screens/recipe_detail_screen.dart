import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/state/app_state.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final PageController _photoController = PageController();
  int _currentPhoto = 0;
  bool _liked = false;

  @override
  void dispose() {
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final hasPhotos = recipe.photoUrls.isNotEmpty;
    final appState = context.watch<AppState>();
    final preferredUnit = appState.measurementUnit;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: hasPhotos ? 260 : 0,
            backgroundColor: const Color(0xFFE85D26),
            foregroundColor: Colors.white,
            flexibleSpace: hasPhotos
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _photoController,
                          onPageChanged: (i) => setState(() => _currentPhoto = i),
                          itemCount: recipe.photoUrls.length,
                          itemBuilder: (context, index) => Container(
                            color: const Color(0xFFFFE4D1),
                            child: const Center(
                              child: Text('📷', style: TextStyle(fontSize: 50)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(recipe.photoUrls.length, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPhoto == index
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.4),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  // Creator name + chef rank badge
                  Row(
                    children: [
                      Text('by ${recipe.creatorName}', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(width: 8),
                      _ChefRankBadge(creatorName: recipe.creatorName),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('${recipe.timeMinutes} min', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(width: 16),
                      const Icon(Icons.star_rounded, size: 18, color: Color(0xFFE85D26)),
                      const SizedBox(width: 4),
                      Text(
                        recipe.ratingCount == 0
                            ? 'No ratings yet'
                            : '${recipe.rating.toStringAsFixed(1)} (${recipe.ratingCount})',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _liked ? Icons.favorite : Icons.favorite_border,
                          color: _liked ? Colors.red : Colors.grey.shade400,
                        ),
                        onPressed: () => setState(() => _liked = !_liked),
                      ),
                    ],
                  ),
                  if (recipe.videoUrl != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (recipe.ingredientDetails.isEmpty)
                    Text(
                      recipe.requiredIngredients.join(', '),
                      style: TextStyle(color: Colors.grey.shade700, height: 1.6),
                    )
                  else
                    ...recipe.ingredientDetails.map((i) {
                      final converted = i.convertedTo(preferredUnit);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6, color: Color(0xFFE85D26)),
                            const SizedBox(width: 10),
                            Text(converted.display, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  const Text('Steps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (recipe.steps.isEmpty)
                    Text('No steps added yet.', style: TextStyle(color: Colors.grey.shade500))
                  else
                    ...recipe.steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${index + 1}: ${step.title}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(step.description, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // Backend needed: real comments require stored user accounts
                  // and a comments table. Placeholder shown for now.
                  Text('Be the first to comment.', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

/// Small inline badge showing a chef rank next to a creator name.
/// For now, maps known sample creator names to placeholder ranks.
class _ChefRankBadge extends StatelessWidget {
  final String creatorName;

  const _ChefRankBadge({required this.creatorName});

  @override
  Widget build(BuildContext context) {
    // For user-uploaded recipes, show the user's own rank.
    // For sample/other recipes, show a placeholder rank based on creator name.
    final appState = context.watch<AppState>();
    final ChefRank rank;

    if (creatorName == appState.username) {
      rank = appState.chefRank;
    } else {
      // Placeholder rank for sample recipe creators
      rank = ChefRank.sousChef;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4D1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${rank.emoji} ${rank.displayName}',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}