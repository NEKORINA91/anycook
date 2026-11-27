import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/ui.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _currentPhoto = 0;
  bool _liked = false;
  final _methodKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final s = context.watch<AppState>();
    final wide = isWide(context);
    final pantry = s.pantryIngredients;
    final missing = missingFor(recipe, pantry);
    final missingAppliances = s.appliances.isEmpty
        ? <String>[]
        : recipe.requiredAppliances.where((a) => !s.appliances.contains(a)).toList();
    final rank = recipe.creatorName == s.username ? s.chefRank : ChefRank.sousChef; // placeholder for sample chefs
    final photoCount = recipe.photoUrls.isEmpty ? 1 : recipe.photoUrls.length;

    // ── Left: photo + thumbnails ───────────────────────────────────────────
    final gallery = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FoodArt(
          seed: '${recipe.name}$_currentPhoto',
          height: wide ? 440 : 260,
          radius: 28,
          iconSize: wide ? 120 : 80,
        ),
        if (photoCount > 1) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < photoCount; i++)
                Semantics(
                  button: true,
                  label: 'Photo ${i + 1}',
                  selected: i == _currentPhoto,
                  child: GestureDetector(
                    onTap: () => setState(() => _currentPhoto = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: i == _currentPhoto ? AppColors.ink : Colors.transparent, width: 2),
                      ),
                      child: SizedBox(
                        width: 80,
                        height: 60,
                        child: FoodArt(seed: '${recipe.name}$i', height: 60, radius: 12, iconSize: 22),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );

    // ── Right: title, chef, stats, actions ─────────────────────────────────
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (missingAppliances.isNotEmpty)
              Tag(label: 'Needs ${missingAppliances.join(', ').toLowerCase()}', bg: AppColors.redBg, ink: AppColors.redInk)
            else if (recipe.requiredAppliances.isNotEmpty)
              Tag(label: 'Works in your kitchen', bg: AppColors.greenBg, ink: AppColors.greenInk),
            if (pantry.isNotEmpty) TierBadge(recipe: recipe, pantry: pantry),
          ],
        ),
        const SizedBox(height: 16),
        Text(recipe.name, style: AppTheme.display(size: wide ? 60 : 38, weight: FontWeight.w300, height: 1.02)),
        const SizedBox(height: 18),
        Row(
          children: [
            Avatar(name: recipe.creatorName, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.creatorName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(rank.displayName, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _StatTile(label: 'Time', value: '${recipe.timeMinutes} min')),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Rating',
                value: recipe.ratingCount == 0 ? 'New' : '${recipe.rating.toStringAsFixed(1)} ★',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                label: 'Appliance',
                value: recipe.requiredAppliances.isEmpty ? 'None' : recipe.requiredAppliances.first,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton(
              onPressed: () {
                final ctx = _methodKey.currentContext;
                if (ctx != null) {
                  Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
                }
              },
              child: const Text('Start cooking'),
            ),
            _RoundIconButton(
              tooltip: _liked ? 'Unlike' : 'Like',
              icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _liked ? AppColors.redInk : AppColors.ink,
              onTap: () => setState(() => _liked = !_liked),
            ),
            _RoundIconButton(
              tooltip: 'Share',
              icon: Icons.ios_share_rounded,
              onTap: () => showSoon(context, 'Sharing'),
            ),
          ],
        ),
      ],
    );

    // ── Ingredients card ────────────────────────────────────────────────────
    final haveSet = pantry.map((p) => p.toLowerCase().trim()).toSet();
    final List<({String name, String amount})> rows = recipe.ingredientDetails.isNotEmpty
        ? [
            for (final i in recipe.ingredientDetails)
              () {
                final c = i.convertedTo(s.measurementUnit);
                final amt = c.amount % 1 == 0 ? c.amount.toInt().toString() : c.amount.toStringAsFixed(1);
                return (name: i.name, amount: '$amt ${c.unit}');
              }(),
          ]
        : [for (final n in recipe.requiredIngredients) (name: n, amount: '')];

    final ingredients = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text('Ingredients', style: AppTheme.display(size: 26)),
              SegmentedPill(
                options: const ['Metric', 'Imperial'],
                selected: s.measurementUnit == MeasurementUnit.metric ? 0 : 1,
                onChanged: (i) => s.setMeasurementUnit(i == 0 ? MeasurementUnit.metric : MeasurementUnit.imperial),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final r in rows)
            _IngredientRow(
              name: _capitalise(r.name),
              amount: r.amount,
              have: pantry.isEmpty ? null : haveSet.contains(r.name.toLowerCase().trim()),
            ),
          if (pantry.isNotEmpty && missing.isNotEmpty) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => showSoon(context, 'The shopping list'),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.accentSoft,
                foregroundColor: AppColors.accentInk,
                minimumSize: const Size.fromHeight(46),
              ),
              child: Text('Add ${missing.length} missing to shopping list'),
            ),
          ],
          if (pantry.isEmpty) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => goToTab(context, NavTab.kitchen),
              child: const Text('Add your pantry to see what you have'),
            ),
          ],
        ],
      ),
    );

    // ── Method + comments ───────────────────────────────────────────────────
    final method = Column(
      key: _methodKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Method', style: AppTheme.display(size: 26)),
        const SizedBox(height: 8),
        if (recipe.steps.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No steps added yet.', style: TextStyle(color: AppColors.muted)),
          )
        else
          for (var i = 0; i < recipe.steps.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: AppTheme.display(size: 36, weight: FontWeight.w300, color: AppColors.accent, height: 1),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recipe.steps[i].title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        if (recipe.steps[i].description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(recipe.steps[i].description,
                              style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.muted)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 20),
        SectionCard(
          color: AppColors.stone,
          borderColor: null,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Comments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('No comments yet. Cooked it? Tell ${recipe.creatorName} how it went.',
                  style: const TextStyle(fontSize: 14, color: AppColors.muted)),
              const SizedBox(height: 12),
              // Backend needed: real comments need accounts + a comments table.
              const TextField(
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(hintText: 'Mine came out fluffy, I swapped butter for oil'),
              ),
            ],
          ),
        ),
      ],
    );

    return AppShell(
      current: NavTab.none,
      body: PageWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggerIn(context, [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: TextButton.styleFrom(foregroundColor: AppColors.muted),
              ),
            ),
            const SizedBox(height: 12),
            SplitLayout(first: gallery, second: info, firstFlex: 11, secondFlex: 9, gap: 40),
            SizedBox(height: wide ? 48 : 32),
            SplitLayout(first: ingredients, second: method, firstFlex: 2, secondFlex: 3, gap: 40),
          ]),
        ),
      ),
    );
  }

  static String _capitalise(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.display(size: 20)),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String name;
  final String amount;
  final bool? have; // null = pantry not set up

  const _IngredientRow({required this.name, required this.amount, required this.have});

  @override
  Widget build(BuildContext context) {
    final h = have;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF1ECE6)))),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: h == null ? AppColors.stone : (h ? AppColors.greenInk : const Color(0xFFB45309)),
              shape: BoxShape.circle,
            ),
            child: h == null
                ? null
                : Icon(h ? Icons.check_rounded : Icons.add_rounded, size: 14, color: Colors.white,
                    semanticLabel: h ? 'You have this' : 'Missing'),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 15))),
          Text(amount, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundIconButton({required this.tooltip, required this.icon, required this.onTap, this.color = AppColors.ink});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(48, 48),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.lineStrong),
      ),
    );
  }
}
