import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/ui.dart';

/// "My kitchen": appliances and pantry on one page (replaces the old
/// separate My Appliances and My Pantry screens). Changes save instantly.
class KitchenSetupScreen extends StatefulWidget {
  const KitchenSetupScreen({super.key});

  @override
  State<KitchenSetupScreen> createState() => _KitchenSetupScreenState();
}

class _KitchenSetupScreenState extends State<KitchenSetupScreen> {
  static const allAppliances = [
    'Stovetop', 'Microwave', 'Kettle', 'Oven', 'Air Fryer', 'Rice Cooker', 'Blender', 'Toaster',
  ];
  static const applianceIcons = {
    'Stovetop': Icons.local_fire_department_outlined,
    'Microwave': Icons.microwave_outlined,
    'Kettle': Icons.coffee_maker_outlined,
    'Oven': Icons.countertops_outlined,
    'Air Fryer': Icons.air_rounded,
    'Rice Cooker': Icons.rice_bowl_outlined,
    'Blender': Icons.blender_outlined,
    'Toaster': Icons.breakfast_dining_outlined,
  };
  static const commonIngredients = [
    'Flour', 'Rice', 'Eggs', 'Egg', 'Milk', 'Butter', 'Sugar', 'Salt', 'Onion', 'Garlic', 'Tomato',
    'Potato', 'Carrot', 'Chicken', 'Beef', 'Fish', 'Cheese', 'Yogurt', 'Bread', 'Pasta', 'Oil',
    'Pepper', 'Ginger', 'Lemon', 'Coconut Milk',
  ];

  final _ingredient = TextEditingController();

  @override
  void dispose() {
    _ingredient.dispose();
    super.dispose();
  }

  void _toggle(AppState s, String appliance) {
    final next = List<String>.from(s.appliances);
    if (next.contains(appliance)) {
      next.remove(appliance);
    } else {
      next.add(appliance);
    }
    s.setAppliances(next);
  }

  void _add(AppState s, String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    // Title-case so "rice" matches recipes that list "Rice".
    s.addIngredient(v[0].toUpperCase() + v.substring(1));
    _ingredient.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final wide = isWide(context);
    final q = _ingredient.text.trim().toLowerCase();
    final suggestions = q.isEmpty
        ? <String>[]
        : commonIngredients
            .where((i) => i.toLowerCase().contains(q) && !s.pantryIngredients.contains(i))
            .take(6)
            .toList();

    final makeable = s.allRecipes.where((r) => s.appliances.isEmpty || r.hasRequiredAppliances(s.appliances)).toList();
    final green = makeable.where((r) => missingFor(r, s.pantryIngredients).isEmpty).length;
    final amber = makeable.where((r) {
      final m = missingFor(r, s.pantryIngredients).length;
      return m > 0 && m <= 2;
    }).length;

    final appliancesCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 12,
            children: [
              Text('Appliances', style: AppTheme.display(size: 26)),
              Text('${s.appliances.length} selected', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 18),
          AutoGrid(
            minItemWidth: wide ? 150 : 130,
            gap: 12,
            children: [
              for (final a in allAppliances)
                _ApplianceTile(
                  name: a,
                  icon: applianceIcons[a] ?? Icons.kitchen_outlined,
                  selected: s.appliances.contains(a),
                  onTap: () => _toggle(s, a),
                ),
            ],
          ),
        ],
      ),
    );

    final pantryCard = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pantry', style: AppTheme.display(size: 26)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredient,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (v) => _add(s, v),
                  decoration: const InputDecoration(
                    hintText: 'Add an ingredient, like rice or eggs',
                    fillColor: AppColors.bg,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => _add(s, _ingredient.text),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Add'),
              ),
            ],
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final sug in suggestions)
                  ActionChip(
                    label: Text('+ $sug'),
                    onPressed: () => _add(s, sug),
                    backgroundColor: AppColors.accentSoft,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: const TextStyle(color: AppColors.accentInk, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (s.pantryIngredients.isEmpty)
            const Text('Your pantry is empty. Add 3 things to start seeing green matches.',
                style: TextStyle(color: AppColors.muted))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in s.pantryIngredients)
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
                    decoration: BoxDecoration(color: AppColors.stone, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Remove $p',
                          onPressed: () => s.removeIngredient(p),
                          icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.muted),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            minimumSize: const Size(28, 28),
                            fixedSize: const Size(28, 28),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );

    final matches = Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow('Your matches', color: Color(0xFFD6CEC5)),
          const SizedBox(height: 14),
          Text('${makeable.length}', style: AppTheme.display(size: 64, weight: FontWeight.w300, color: Colors.white, height: 1)),
          const SizedBox(height: 10),
          Text(
            s.appliances.isEmpty
                ? 'recipes so far. Pick your appliances to narrow it down to what you can really make.'
                : '${makeable.length == 1 ? 'recipe fits' : 'recipes fit'} your appliances.',
            style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFFD6CEC5)),
          ),
          if (s.pantryIngredients.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Tag(label: '$green all in', bg: AppColors.greenBg, ink: AppColors.greenInk),
                Tag(label: '$amber missing 1–2', bg: AppColors.amberBg, ink: AppColors.amberInk),
              ],
            ),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => goToTab(context, NavTab.search),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentBright,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Show my recipes'),
          ),
        ],
      ),
    );

    return AppShell(
      current: NavTab.kitchen,
      body: PageWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: staggerIn(context, [
            SizedBox(height: wide ? 24 : 8),
            const PageTitle("Tell us what you cook with. We'll do the rest.", eyebrow: 'My kitchen'),
            SizedBox(height: wide ? 36 : 24),
            Split(
              firstFlex: 2,
              secondFlex: 1,
              gap: 28,
              first: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [appliancesCard, const SizedBox(height: 24), pantryCard],
              ),
              second: matches,
            ),
          ]),
        ),
      ),
    );
  }
}

class _ApplianceTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ApplianceTile({required this.name, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? AppColors.accent : AppColors.lineStrong, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22, color: selected ? AppColors.accent : AppColors.muted),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.accent : AppColors.lineStrong,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                  ),
                ],
              ),
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
