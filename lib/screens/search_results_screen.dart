import 'package:flutter/material.dart';
import 'package:anycook/data/sample_recipes.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  bool _sortByTime = false;

  @override
  Widget build(BuildContext context) {
    var results = sampleRecipes
        .where((r) => r.name.toLowerCase().contains(widget.query.toLowerCase()))
        .toList();

    if (_sortByTime) {
      results.sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
        backgroundColor: const Color(0xFFE85D26),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Sort:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Fastest'),
                  selected: _sortByTime,
                  onSelected: (selected) => setState(() => _sortByTime = selected),
                ),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No recipes found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final recipe = results[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(recipe.name),
                          subtitle: Text('${recipe.timeMinutes} min'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}