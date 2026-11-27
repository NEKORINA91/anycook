import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/recipe_card.dart';
import 'package:anycook/widgets/ui.dart';

enum _TimeFilter { under5, under30, any }

class SearchResultsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? filter; // 'topRated' | 'under5min' | 'recent'

  const SearchResultsScreen({super.key, this.searchQuery, this.filter});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _query = TextEditingController(text: widget.searchQuery ?? '');
  late _TimeFilter _time = widget.filter == 'under5min' ? _TimeFilter.under5 : _TimeFilter.any;
  bool _showGreen = true;
  bool _showAmber = true;
  bool _showRed = true;
  bool _sortFastest = false;
  bool _sortBestMatch = false;
  bool _filtersOpen = false; // phone only

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  String get _title {
    final q = _query.text.trim();
    if (q.isNotEmpty) return 'Results for "$q"';
    switch (widget.filter) {
      case 'topRated':
        return 'Top rated';
      case 'under5min':
        return 'Under 5 minutes';
      case 'recent':
        return 'Recent';
      default:
        return 'Find recipes';
    }
  }

  void _reset() => setState(() {
        _time = _TimeFilter.any;
        _showGreen = _showAmber = _showRed = true;
        _sortFastest = _sortBestMatch = false;
      });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final wide = isWide(context);
    final pantry = s.pantryIngredients;
    final appliances = s.appliances;

    // 1. Text search
    var results = List<Recipe>.from(s.allRecipes);
    final q = _query.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      results = results
          .where((r) => r.name.toLowerCase().contains(q) || r.requiredIngredients.any((i) => i.toLowerCase().contains(q)))
          .toList();
    }

    // 2. Time
    if (_time == _TimeFilter.under5) results = results.where((r) => r.timeMinutes <= 5).toList();
    if (_time == _TimeFilter.under30) results = results.where((r) => r.timeMinutes <= 30).toList();

    // 3. Pantry match tiers (only meaningful once the pantry has something)
    if (pantry.isNotEmpty) {
      results = results.where((r) {
        final m = missingFor(r, pantry).length;
        if (m == 0) return _showGreen;
        if (m <= 2) return _showAmber;
        return _showRed;
      }).toList();
    }

    // 4. Appliance hard filter
    var hiddenCount = 0;
    final missingAppliances = <String>{};
    if (s.hideUnmakeableRecipes && appliances.isNotEmpty) {
      final hidden = results.where((r) => !r.hasRequiredAppliances(appliances)).toList();
      for (final r in hidden) {
        missingAppliances.addAll(r.requiredAppliances.where((a) => !appliances.contains(a)));
      }
      hiddenCount = hidden.length;
      results = results.where((r) => r.hasRequiredAppliances(appliances)).toList();
    }

    // 5. Sorting
    if (widget.filter == 'topRated') results.sort((a, b) => b.rating.compareTo(a.rating));
    if (widget.filter == 'recent') results = results.reversed.toList();
    if (_sortFastest) results.sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    if (_sortBestMatch && pantry.isNotEmpty) {
      results.sort((a, b) => missingFor(a, pantry).length.compareTo(missingFor(b, pantry).length));
    }

    final filters = _FiltersPanel(
      appliances: appliances,
      hideUnmakeable: s.hideUnmakeableRecipes,
      onHideUnmakeable: s.setHideUnmakeableRecipes,
      time: _time,
      onTime: (t) => setState(() => _time = t),
      pantryReady: pantry.isNotEmpty,
      green: _showGreen,
      amber: _showAmber,
      red: _showRed,
      onGreen: (v) => setState(() => _showGreen = v),
      onAmber: (v) => setState(() => _showAmber = v),
      onRed: (v) => setState(() => _showRed = v),
      onReset: _reset,
    );

    final resultsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 12,
          children: [
            Text(_title, style: AppTheme.display(size: wide ? 44 : 32, weight: FontWeight.w300)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (!wide)
                  FilterPill(
                    label: _filtersOpen ? 'Hide filters' : 'Filters',
                    selected: _filtersOpen,
                    onTap: () => setState(() => _filtersOpen = !_filtersOpen),
                  ),
                FilterPill(
                  label: 'Fastest',
                  selected: _sortFastest,
                  onTap: () => setState(() {
                    _sortFastest = !_sortFastest;
                    if (_sortFastest) _sortBestMatch = false;
                  }),
                ),
                if (pantry.isNotEmpty)
                  FilterPill(
                    label: 'Best match',
                    selected: _sortBestMatch,
                    onTap: () => setState(() {
                      _sortBestMatch = !_sortBestMatch;
                      if (_sortBestMatch) _sortFastest = false;
                    }),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${results.length} ${results.length == 1 ? 'recipe' : 'recipes'}'
          '${hiddenCount > 0 ? ' · $hiddenCount hidden' : ''}',
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        if (!wide && _filtersOpen) ...[const SizedBox(height: 16), filters],
        const SizedBox(height: 20),
        if (results.isEmpty)
          SectionCard(
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 40, color: AppColors.muted),
                const SizedBox(height: 10),
                Text('No recipes found', style: AppTheme.display(size: 22)),
                const SizedBox(height: 6),
                const Text('Try another word, or loosen the filters.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted)),
              ],
            ),
          )
        else
          AutoGrid(
            minItemWidth: wide ? 240 : 160,
            gap: wide ? 18 : 12,
            children: [for (final r in results) RecipeCard(recipe: r, imageHeight: wide ? 160 : 120)],
          ),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD6CEC5)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  '$hiddenCount ${hiddenCount == 1 ? 'recipe is' : 'recipes are'} hidden because '
                  '${hiddenCount == 1 ? 'it needs' : 'they need'}: ${missingAppliances.join(', ').toLowerCase()}.',
                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                TextButton(
                  onPressed: () => goToTab(context, NavTab.kitchen),
                  child: const Text('Got one? Add it to My kitchen'),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return AppShell(
      current: NavTab.search,
      body: PageWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (v) => context.read<AppState>().addSearchTerm(v),
              decoration: InputDecoration(
                hintText: 'Search recipes or ingredients',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(_query.clear),
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppColors.lineStrong)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppColors.lineStrong)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
              ),
            ),
            const SizedBox(height: 28),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 280, child: filters),
                  const SizedBox(width: 32),
                  Expanded(child: resultsColumn),
                ],
              )
            else
              resultsColumn,
          ],
        ),
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final List<String> appliances;
  final bool hideUnmakeable;
  final ValueChanged<bool> onHideUnmakeable;
  final _TimeFilter time;
  final ValueChanged<_TimeFilter> onTime;
  final bool pantryReady;
  final bool green, amber, red;
  final ValueChanged<bool> onGreen, onAmber, onRed;
  final VoidCallback onReset;

  const _FiltersPanel({
    required this.appliances,
    required this.hideUnmakeable,
    required this.onHideUnmakeable,
    required this.time,
    required this.onTime,
    required this.pantryReady,
    required this.green,
    required this.amber,
    required this.red,
    required this.onGreen,
    required this.onAmber,
    required this.onRed,
    required this.onReset,
  });

  Widget _check(String label, bool value, ValueChanged<bool> onChanged, Color color) {
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(22),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                TextButton(onPressed: onReset, child: const Text('Reset')),
              ],
            ),
            const SizedBox(height: 12),
            const Eyebrow('My appliances'),
            const SizedBox(height: 8),
            Text(
              appliances.isEmpty ? 'None set yet' : appliances.join(', '),
              style: const TextStyle(fontSize: 14, color: AppColors.muted),
            ),
            SwitchListTile(
              value: hideUnmakeable,
              onChanged: appliances.isEmpty ? null : onHideUnmakeable,
              title: const Text("Hide recipes I can't make", style: TextStyle(fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            TextButton(
              onPressed: () => goToTab(context, NavTab.kitchen),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Edit my kitchen'),
            ),
            const SizedBox(height: 18),
            const Eyebrow('Time'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterPill(label: 'Under 5', selected: time == _TimeFilter.under5, onTap: () => onTime(_TimeFilter.under5)),
                FilterPill(label: 'Under 30', selected: time == _TimeFilter.under30, onTap: () => onTime(_TimeFilter.under30)),
                FilterPill(label: 'Any', selected: time == _TimeFilter.any, onTap: () => onTime(_TimeFilter.any)),
              ],
            ),
            const SizedBox(height: 22),
            const Eyebrow('Pantry match'),
            const SizedBox(height: 4),
            if (!pantryReady)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Add your pantry in My kitchen to filter by what you have.',
                    style: TextStyle(fontSize: 13, color: AppColors.muted)),
              )
            else ...[
              _check('All ingredients', green, onGreen, AppColors.greenInk),
              _check('Missing 1–2', amber, onAmber, const Color(0xFFB45309)),
              _check('Missing 3 or more', red, onRed, AppColors.redInk),
            ],
          ],
        ),
      ),
    );
  }
}
