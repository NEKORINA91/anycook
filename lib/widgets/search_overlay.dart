import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/search_results_screen.dart';

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
      if (query.isEmpty) {
        _suggestions = [];
      } else {
        _suggestions = appState.allRecipes
            .map((r) => r.name)
            .where((name) => name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _runSearch(String query) {
    if (query.isEmpty) return;
    context.read<AppState>().addSearchTerm(query);
    widget.onClose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final showHistory =
        _controller.text.isEmpty && appState.searchHistory.isNotEmpty;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            // Swallow taps on the search box itself so tapping inside
            // it doesn't trigger the "tap outside to close" above.
            child: GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  // ── Search input bar ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            onChanged: _updateSuggestions,
                            onSubmitted: _runSearch,
                            decoration: const InputDecoration(
                              hintText: 'Search recipes...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: widget.onClose,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Search history (when query is empty) ──────────────
                  if (showHistory)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Text(
                                  'Recent Searches',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () =>
                                      appState.clearSearchHistory(),
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...appState.searchHistory.map((term) {
                            return ListTile(
                              leading: Icon(Icons.access_time,
                                  color: Colors.grey.shade400, size: 20),
                              title: Text(term),
                              dense: true,
                              onTap: () => _runSearch(term),
                            );
                          }),
                        ],
                      ),
                    ),

                  // ── Live suggestions (when typing) ────────────────────
                  if (_suggestions.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: _suggestions.map((s) {
                          return ListTile(
                            leading: const Icon(Icons.search,
                                color: Colors.grey, size: 20),
                            title: Text(s),
                            dense: true,
                            onTap: () => _runSearch(s),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}