import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/recipe_card.dart';
import 'package:anycook/widgets/search_overlay.dart';
import 'package:anycook/widgets/ui.dart';
import 'package:anycook/screens/recipe_detail_screen.dart';
import 'package:anycook/screens/search_results_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

enum _HomeFilter { all, under5, topRated, recent }

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  bool _showSearch = false;
  _HomeFilter _filter = _HomeFilter.all;

  String _greeting(AppState s) {
    final h = DateTime.now().hour;
    final part = h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
    return s.isLoggedIn && s.username.isNotEmpty ? '$part, ${s.username}' : part;
  }

  List<Recipe> _filtered(List<Recipe> all) {
    final list = List<Recipe>.from(all);
    switch (_filter) {
      case _HomeFilter.under5:
        return list.where((r) => r.timeMinutes <= 5).toList();
      case _HomeFilter.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        return list;
      case _HomeFilter.recent:
        return list.reversed.toList();
      case _HomeFilter.all:
        return list;
    }
  }

  void _openSearch(String? query, {String? filter}) {
    if (query != null) context.read<AppState>().addSearchTerm(query);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsScreen(searchQuery: query, filter: filter)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final wide = isWide(context);

    // Recipes the user can make with their appliances (all, if none set yet).
    final makeable = s.allRecipes
        .where((r) => s.appliances.isEmpty || r.hasRequiredAppliances(s.appliances))
        .toList();
    final ready = s.pantryIngredients.isEmpty
        ? <Recipe>[]
        : makeable.where((r) => missingFor(r, s.pantryIngredients).isEmpty).toList();
    final featured = ready.isNotEmpty ? ready.first : (makeable.isNotEmpty ? makeable.first : null);
    final recipes = _filtered(makeable);

    return AppShell(
      current: NavTab.discover,
      glow: true,
      overlay: _showSearch ? SearchOverlay(onClose: () => setState(() => _showSearch = false)) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: staggerIn(context, [
          // ── Hero ───────────────────────────────────────────────────────
          PageWidth(
            child: Padding(
              padding: EdgeInsets.only(top: wide ? 48 : 16, bottom: wide ? 32 : 20),
              child: Split(
                align: CrossAxisAlignment.center,
                gap: 48,
                first: _HeroText(
                  greeting: _greeting(s),
                  onSearch: () => setState(() => _showSearch = true),
                  onFind: () => _openSearch(null),
                ),
                second: wide
                    ? _HeroCards(
                        appliances: s.appliances,
                        readyCount: ready.length,
                        total: s.allRecipes.length,
                        pantryEmpty: s.pantryIngredients.isEmpty,
                        featured: featured,
                        pantry: s.pantryIngredients,
                      )
                    : _PantryMatchCard(
                        readyCount: ready.length,
                        total: s.allRecipes.length,
                        pantryEmpty: s.pantryIngredients.isEmpty,
                        compact: true,
                      ),
              ),
            ),
          ),

          // ── Suggestion prompts ─────────────────────────────────────────
          PageWidth(
            child: Padding(
              padding: EdgeInsets.only(bottom: wide ? 56 : 28),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _PromptChip(label: 'Use up leftover rice', onTap: () => _openSearch('rice')),
                  _PromptChip(label: 'Something with eggs', onTap: () => _openSearch('egg')),
                  _PromptChip(label: 'Ready in under 5 minutes', onTap: () => _openSearch(null, filter: 'under5min')),
                  _PromptChip(label: 'Top rated by the community', onTap: () => _openSearch(null, filter: 'topRated')),
                ],
              ),
            ),
          ),

          // ── Recipes you can make ───────────────────────────────────────
          PageWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  eyebrow: 'Picked for your kitchen',
                  title: 'Recipes you can make',
                  trailing: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterPill(label: 'All', selected: _filter == _HomeFilter.all, onTap: () => setState(() => _filter = _HomeFilter.all)),
                      FilterPill(label: 'Under 5 min', selected: _filter == _HomeFilter.under5, onTap: () => setState(() => _filter = _HomeFilter.under5)),
                      FilterPill(label: 'Top rated', selected: _filter == _HomeFilter.topRated, onTap: () => setState(() => _filter = _HomeFilter.topRated)),
                      FilterPill(label: 'Recent', selected: _filter == _HomeFilter.recent, onTap: () => setState(() => _filter = _HomeFilter.recent)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (recipes.isEmpty)
                  const SectionCard(
                    child: Text('Nothing here yet. Try another filter, or add more appliances in My kitchen.',
                        style: TextStyle(color: AppColors.muted)),
                  )
                else
                  AutoGrid(
                    minItemWidth: wide ? 260 : 160,
                    gap: wide ? 20 : 12,
                    children: [
                      for (final r in recipes) RecipeCard(recipe: r, imageHeight: wide ? 180 : 120),
                    ],
                  ),
              ],
            ),
          ),

          // ── How it works ───────────────────────────────────────────────
          PageWidth(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: wide ? 72 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      'Three steps to never asking "what can I even make?"',
                      style: AppTheme.display(size: wide ? 40 : 26),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const AutoGrid(
                    minItemWidth: 240,
                    children: [
                      _StepCard(n: '01', title: 'Pick your appliances', text: "Only a kettle and a microwave? We'll hide anything that needs an oven.", bg: AppColors.accentSoft, ink: AppColors.accent),
                      _StepCard(n: '02', title: 'Add your pantry', text: "Type what's in your cupboard and fridge. Missing a thing or two is fine.", bg: AppColors.lilac, ink: AppColors.lilacInk),
                      _StepCard(n: '03', title: 'Cook what fits', text: 'Green means you have everything. Amber means one quick shop.', bg: AppColors.mint, ink: AppColors.greenInk),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Footer ─────────────────────────────────────────────────────
          const Divider(),
          const PageWidth(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text('AnyCook — a portfolio project by NEKORINA91', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  Text('Made for kitchens of every size', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeroText extends StatelessWidget {
  final String greeting;
  final VoidCallback onSearch;
  final VoidCallback onFind;

  const _HeroText({required this.greeting, required this.onSearch, required this.onFind});

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wide
            ? const Eyebrow('Recipes that fit your kitchen', dot: true)
            : Text(greeting, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
        SizedBox(height: wide ? 22 : 6),
        Text(
          wide ? "Cook with what's already in your kitchen." : 'What can you cook tonight?',
          style: AppTheme.display(size: wide ? 72 : 38, weight: FontWeight.w300, height: 1.02),
        ),
        if (wide) ...[
          const SizedBox(height: 22),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const Text(
              "Tell AnyCook which appliances you own and what's in your pantry. Every recipe you see is one you can actually make tonight.",
              style: TextStyle(fontSize: 18, height: 1.6, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onFind,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                iconAlignment: IconAlignment.end,
                label: const Text('Find my recipes'),
              ),
              OutlinedButton(
                onPressed: () => goToTab(context, NavTab.kitchen),
                child: const Text('Set up my kitchen'),
              ),
            ],
          ),
        ],
        SizedBox(height: wide ? 26 : 18),
        _SearchPill(onTap: onSearch),
      ],
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search recipes',
      child: Pressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.lineStrong),
            boxShadow: [
              BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Search recipes or ingredients', style: TextStyle(fontSize: 15, color: AppColors.muted)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(999)),
                child: const Text('Search', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PantryMatchCard extends StatelessWidget {
  final int readyCount;
  final int total;
  final bool pantryEmpty;
  final bool compact;

  const _PantryMatchCard({required this.readyCount, required this.total, required this.pantryEmpty, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final title = pantryEmpty
        ? 'Add your pantry to see what you can make'
        : '$readyCount ${readyCount == 1 ? 'recipe' : 'recipes'} you can make right now';
    final fraction = total == 0 ? 0.0 : (readyCount / total).clamp(0.0, 1.0).toDouble();

    return Pressable(
      onTap: () => goToTab(context, NavTab.kitchen),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.lilac,
          borderRadius: BorderRadius.circular(compact ? 22 : 20),
          boxShadow: compact
              ? null
              : [BoxShadow(color: AppColors.lilacInk.withValues(alpha: 0.12), blurRadius: 50, offset: const Offset(0, 20))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Pantry match', color: AppColors.lilacInk),
                  const SizedBox(height: 8),
                  Text(title, style: AppTheme.display(size: compact ? 20 : 22, color: AppColors.lilacDeep, height: 1.2)),
                  if (!compact) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFD9CFF6),
                        color: const Color(0xFF6D55D1),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (compact) ...[
              const SizedBox(width: 14),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.lilacDeep, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The floating-cards composition on the right of the desktop hero.
class _HeroCards extends StatelessWidget {
  final List<String> appliances;
  final int readyCount;
  final int total;
  final bool pantryEmpty;
  final Recipe? featured;
  final List<String> pantry;

  const _HeroCards({
    required this.appliances,
    required this.readyCount,
    required this.total,
    required this.pantryEmpty,
    required this.featured,
    required this.pantry,
  });

  BoxDecoration _float() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.08), blurRadius: 50, offset: const Offset(0, 20))],
      );

  @override
  Widget build(BuildContext context) {
    final f = featured;
    final shown = appliances.take(3).toList();

    return SizedBox(
      height: 460,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Your kitchen
          Positioned(
            left: 0,
            top: 30,
            width: 250,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: _float(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your kitchen', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final a in shown) Tag(label: a, bg: AppColors.accentSoft, ink: AppColors.accentInk),
                      GestureDetector(
                        onTap: () => goToTab(context, NavTab.kitchen),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFD6CEC5)),
                          ),
                          child: Text(shown.isEmpty ? '+ Add appliances' : '+ Add',
                              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Pantry match
          Positioned(
            right: 0,
            top: 0,
            width: 250,
            child: _PantryMatchCard(readyCount: readyCount, total: total, pantryEmpty: pantryEmpty),
          ),
          // Featured recipe
          if (f != null)
            Positioned(
              left: 70,
              top: 160,
              width: 320,
              child: Pressable(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: f))),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: _float().copyWith(borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FoodArt(seed: f.name, height: 150, iconSize: 60),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(f.name, style: AppTheme.display(size: 18, weight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                          ),
                          if (pantry.isNotEmpty) TierBadge(recipe: f, pantry: pantry),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${f.timeMinutes} min · ${f.requiredAppliances.join(', ')} · ${f.creatorName}',
                        style: const TextStyle(fontSize: 13, color: AppColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Dark pill
          Positioned(
            right: 20,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
              decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(999)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(color: AppColors.accentBright, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    appliances.isEmpty
                        ? 'Showing every recipe'
                        : 'Matched to ${appliances.length} ${appliances.length == 1 ? 'appliance' : 'appliances'}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.accentBright, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String n;
  final String title;
  final String text;
  final Color bg;
  final Color ink;

  const _StepCard({required this.n, required this.title, required this.text, required this.bg, required this.ink});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: bg,
      borderColor: null,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n, style: AppTheme.display(size: 44, weight: FontWeight.w300, color: ink)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.muted)),
        ],
      ),
    );
  }
}
