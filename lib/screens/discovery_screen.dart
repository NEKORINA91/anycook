import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/kitchen_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:anycook/widgets/hero_banner.dart';
import 'package:anycook/widgets/recipe_card.dart';
import 'package:anycook/screens/pantry_screen.dart';
import 'package:anycook/screens/login_screen.dart';
import 'package:anycook/widgets/search_overlay.dart';
import 'package:anycook/widgets/quick_link_card.dart';
import 'package:anycook/screens/search_results_screen.dart';
import 'package:anycook/screens/recipe_upload_screen.dart';
import 'package:anycook/screens/profile_screen.dart';
import 'package:anycook/screens/settings_screen.dart';


class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final allRecipes = appState.allRecipes;
    final quickRecipes = allRecipes.where((r) => r.timeMinutes <= 5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person, color: Color(0xFFE85D26)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.isLoggedIn ? appState.username : 'Guest',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (appState.isLoggedIn)
                          Text(
                            '${appState.chefRank.emoji} ${appState.chefRank.displayName}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Color(0xFFE85D26)),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.kitchen, color: Color(0xFFE85D26)),
                title: const Text('My Appliances'),
                subtitle: Text(
                  appState.appliances.isEmpty ? 'Not set' : appState.appliances.join(', '),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KitchenSetupScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_basket, color: Color(0xFFE85D26)),
                title: const Text('My Pantry'),
                subtitle: Text(
                  appState.pantryIngredients.isEmpty ? 'Not set' : appState.pantryIngredients.join(', '),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PantryScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_rounded, color: Color(0xFFE85D26)),
                title: const Text('Upload Recipe'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecipeUploadScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFFE85D26)),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.grey),
                title: Text(appState.isLoggedIn ? 'Log Out' : 'Log In'),
                onTap: () {
                  Navigator.pop(context);
                  if (appState.isLoggedIn) {
                    appState.logout();
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeUploadScreen()),
          );
        },
        backgroundColor: const Color(0xFFE85D26),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Color(0xFFE85D26)),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AnyCook',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _showSearch = true),
              child: Container(
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
            ),
            const SizedBox(height: 20),
            const HeroBanner(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QuickLinkCard(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFE85D26),
                  title: 'Top Rated',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchResultsScreen(filter: 'topRated'),
                      ),
                    );
                  },
                ),
                QuickLinkCard(
                  icon: Icons.history_rounded,
                  iconColor: Colors.blueGrey,
                  title: 'Recent',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchResultsScreen(filter: 'recent'),
                      ),
                    );
                  },
                ),
                QuickLinkCard(
                  icon: Icons.timer_rounded,
                  iconColor: Colors.green,
                  title: 'Under 5 Min',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchResultsScreen(filter: 'under5min'),
                      ),
                    );
                  },
                ),
              ],
            ),
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
                children: allRecipes.map((r) => RecipeCard(recipe: r)).toList(),
              ),
            ),
          ],
        ),
              ),
            ),
          ),
          if (_showSearch)
            SearchOverlay(onClose: () => setState(() => _showSearch = false)),
        ],
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