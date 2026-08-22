import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/screens/recipe_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? filter;

  const SearchResultsScreen({super.key, this.searchQuery, this.filter});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool _sortByTime = false;
  bool _sortByMatch = false;

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

  String _tierLabel(MatchTier tier) {
    switch (tier) {
      case MatchTier.green:
        return 'Have all';
      case MatchTier.yellow:
        return 'Missing 1–2';
      case MatchTier.red:
        return 'Missing 3+';
    }
  }

  String get _appBarTitle {
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      return 'Results for "${widget.searchQuery}"';
    }
    switch (widget.filter) {
      case 'topRated':
        return 'Top Rated';
      case 'under5min':
        return 'Under 5 Minutes';
      case 'recent':
        return 'Recent';
      default:
        return 'Find Recipes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allRecipes = appState.allRecipes;
    final userIngredients = appState.pantryIngredients;
    final userAppliances = appState.appliances;

    // ── Step 1: Start with all recipes ──────────────────────────────────────
    var results = List<Recipe>.from(allRecipes);

    // ── Step 2: Text search filter ──────────────────────────────────────────
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      final query = widget.searchQuery!.toLowerCase();
      results = results
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.requiredIngredients
                  .any((i) => i.toLowerCase().contains(query)))
          .toList();
    }

    // ── Step 3: Quick-link filter ───────────────────────────────────────────
    if (widget.filter == 'topRated') {
      results.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (widget.filter == 'under5min') {
      results = results.where((r) => r.timeMinutes <= 5).toList();
    }
    // 'recent' just shows all — no special filter

    // ── Step 4: Appliance hard filter (when toggle is ON) ───────────────────
    int hiddenCount = 0;
    Set<String> missingAppliances = {};

    if (appState.hideUnmakeableRecipes && userAppliances.isNotEmpty) {
      final before = results.length;
      final hidden = results.where((r) => !r.hasRequiredAppliances(userAppliances)).toList();
      for (final r in hidden) {
        for (final a in r.requiredAppliances) {
          if (!userAppliances.contains(a)) {
            missingAppliances.add(a);
          }
        }
      }
      results = results.where((r) => r.hasRequiredAppliances(userAppliances)).toList();
      hiddenCount = before - results.length;
    }

    // ── Step 5: Sort options ────────────────────────────────────────────────
    if (_sortByTime) {
      results.sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    }
    if (_sortByMatch && userIngredients.isNotEmpty) {
      results.sort((a, b) => a
          .matchTier(userIngredients)
          .index
          .compareTo(b.matchTier(userIngredients).index));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: const Color(0xFFE85D26),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // ── Sort chips ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Sort:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Fastest'),
                      selected: _sortByTime,
                      selectedColor: const Color(0xFFFFE4D1),
                      onSelected: (v) => setState(() {
                        _sortByTime = v;
                        if (v) _sortByMatch = false;
                      }),
                    ),
                    const SizedBox(width: 8),
                    if (userIngredients.isNotEmpty)
                      ChoiceChip(
                        label: const Text('Best Match'),
                        selected: _sortByMatch,
                        selectedColor: const Color(0xFFFFE4D1),
                        onSelected: (v) => setState(() {
                          _sortByMatch = v;
                          if (v) _sortByTime = false;
                        }),
                      ),
                  ],
                ),
              ),

              // ── Hidden-recipes notice ─────────────────────────────────────
              if (hiddenCount > 0)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D26).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE85D26).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFE85D26), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$hiddenCount recipe${hiddenCount == 1 ? '' : 's'} hidden — missing: ${missingAppliances.join(', ')}',
                          style: const TextStyle(
                            color: Color(0xFFE85D26),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Results list ──────────────────────────────────────────────
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No recipes found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final recipe = results[index];
                          final tier = recipe.matchTier(userIngredients);
                          final missing = recipe.missingIngredients(userIngredients);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            elevation: 0,
                            color: Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: userIngredients.isNotEmpty
                                  ? Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _tierColor(tier).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: _tierColor(tier),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                              title: Text(
                                recipe.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.timer_outlined,
                                          size: 14, color: Colors.grey.shade600),
                                      const SizedBox(width: 4),
                                      Text('${recipe.timeMinutes} min',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey.shade600)),
                                      if (recipe.ratingCount > 0) ...[
                                        const SizedBox(width: 12),
                                        const Icon(Icons.star_rounded,
                                            size: 14, color: Color(0xFFE85D26)),
                                        const SizedBox(width: 2),
                                        Text(
                                          recipe.rating.toStringAsFixed(1),
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (userIngredients.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      missing.isEmpty
                                          ? 'You have everything!'
                                          : 'Missing: ${missing.join(', ')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _tierColor(tier),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: userIngredients.isNotEmpty
                                  ? Text(
                                      _tierLabel(tier),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _tierColor(tier),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailScreen(recipe: recipe),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}