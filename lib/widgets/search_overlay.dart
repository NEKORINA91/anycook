import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/search_results_screen.dart';
import 'package:anycook/theme/app_theme.dart';

/// Full-screen search with recent searches and live suggestions.
class SearchOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const SearchOverlay({super.key, required this.onClose});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateSuggestions(String query) {
    final appState = context.read<AppState>();
    setState(() {
      _suggestions = query.isEmpty
          ? []
          : appState.allRecipes
              .map((r) => r.name)
              .where((name) => name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _runSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<AppState>().addSearchTerm(query);
    widget.onClose();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsScreen(searchQuery: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final showHistory = _controller.text.isEmpty && appState.searchHistory.isNotEmpty;

    Widget row(IconData icon, String text) => ListTile(
          leading: Icon(icon, color: AppColors.muted, size: 20),
          title: Text(text),
          dense: true,
          onTap: () => _runSearch(text),
        );

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: AppColors.ink.withValues(alpha: 0.55),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {}, // taps inside the panel don't close it
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.muted),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  autofocus: true,
                                  onChanged: _updateSuggestions,
                                  onSubmitted: _runSearch,
                                  decoration: const InputDecoration(
                                    hintText: 'Search recipes or ingredients',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Close search',
                                icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                                onPressed: widget.onClose,
                              ),
                            ],
                          ),
                        ),
                        if (showHistory) ...[
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 12, 8, 4),
                            child: Row(
                              children: [
                                Text('RECENT SEARCHES', style: AppTheme.eyebrow()),
                                const Spacer(),
                                TextButton(onPressed: appState.clearSearchHistory, child: const Text('Clear')),
                              ],
                            ),
                          ),
                          ...appState.searchHistory.map((t) => row(Icons.history_rounded, t)),
                          const SizedBox(height: 8),
                        ],
                        if (_suggestions.isNotEmpty) ...[
                          const Divider(),
                          ..._suggestions.map((t) => row(Icons.search_rounded, t)),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
