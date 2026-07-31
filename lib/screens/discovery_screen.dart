import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/kitchen_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:anycook/widgets/hero_banner.dart';
import 'package:anycook/widgets/recipe_card.dart';
import 'package:anycook/data/sample_recipes.dart';


class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quickRecipes = sampleRecipes.where((r) => r.timeMinutes <= 5).toList();
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Color(0xFFE85D26)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AnyCook',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text('Search recipes...', style: TextStyle(color: Colors.grey.shade400)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const HeroBanner(),
            if (appState.isLoggedIn && appState.appliances.isEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Add your appliances for better matches'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const KitchenSetupScreen()),
                        );
                      },
                      child: const Text('Set up'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Under 5 Min', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: quickRecipes.map((r) => RecipeCard(recipe: r)).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('All Recipes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: sampleRecipes.map((r) => RecipeCard(recipe: r)).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFFE85D26),
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
        ],
      ),
    );
  }
}