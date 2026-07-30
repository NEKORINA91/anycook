// ignore: unnecessary_import
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const AnyCookApp());
}

class AnyCookApp extends StatelessWidget {
  const AnyCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnyCook',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE85D26),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🍳',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'AnyCook',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE85D26),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cook with what you have.',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KitchenSetupScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class KitchenSetupScreen extends StatefulWidget {
  const KitchenSetupScreen({super.key});

  @override
  State<KitchenSetupScreen> createState() => _KitchenSetupScreen();
}

class _KitchenSetupScreen extends State<KitchenSetupScreen>{

  List<String> selectedAppliances = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Padding(

        padding: const EdgeInsets.all(16),
        child: Column(
         crossAxisAlignment:CrossAxisAlignment.start,
         children: [
          const Text(
            'Tap what you have:',
            
            style: TextStyle(
              fontSize:22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              'Oven',
              'Microwave',
              'Air Fryer',
              'Stovetop',
              'Rice Cooker',
              'Blender',
            ].map((appliance){
              bool isSelected = selectedAppliances.contains(appliance);
              return GestureDetector(
                onTap: (){
                  setState((){
                    if (isSelected){
                      selectedAppliances.remove(appliance);
                    } else {
                      selectedAppliances.add(appliance);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:isSelected
                      ? const Color(0xFFE85D26)
                      :Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFE85D26),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    appliance,
                    style: TextStyle(
                      color: isSelected
                       ? Colors.white
                       : const Color (0xFFE85D26),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
            const SizedBox (height:30),
            Text(
              selectedAppliances.isEmpty
                ? 'no appliances selected yet'
                : 'Selected:${selectedAppliances.join(',')}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF888888),
              ),  
            ),
            const SizedBox(height:30),
            ElevatedButton(
              onPressed: selectedAppliances.isEmpty
              ? null
              : (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:(context) => PantryScreen(
                      appliances: selectedAppliances,
                    ),
                  ),
                );
              },
              style:ElevatedButton.styleFrom(
                backgroundColor:const Color(0xFFE85D26),
                disabledBackgroundColor:Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape:RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

        ],

      ),

    )
    );
  }
} 

class PantryScreen extends StatefulWidget {
  final List<String> appliances;

  const PantryScreen({
    super.key,
    required this.appliances,
  });

  @override
  State<PantryScreen> createState()=> _PantryScreenState();
  
}
class _PantryScreenState extends State<PantryScreen>{

  final List<String> allIngredients = [
  'Flour', 'Rice', 'Eggs', 'Milk', 'Butter', 'Sugar',
  'Salt', 'Onion', 'Garlic', 'Tomato', 'Potato', 'Carrot',
  'Chicken', 'Beef', 'Fish', 'Cheese', 'Yogurt', 'Bread',
  'Pasta', 'Oil', 'Pepper', 'Ginger', 'Lemon', 'Coconut Milk',
];

List<String> searchResults = [];
final TextEditingController ingredientController = TextEditingController();
List<String> ingredients = [];
void updateSearch(String query){
  setState((){
    if (query.isEmpty){
      searchResults = [];
    } else {
      searchResults = allIngredients
      .where((item) => item.toLowerCase().contains(query.toLowerCase()))
      .toList();
    }
  });
}


    @override
    Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text ('My Pantry'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE85D26),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.appliances.join(', '),
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFFE85D26),
              ),
            ),
            const SizedBox(height:30),
            const Text(
              'What ingredients do you have?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:ingredientController,
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText: 'Search Ingredients...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchResults.map((item) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!ingredients.contains(item)) {
                        ingredients.add(item);
                      }
                      ingredientController.clear();
                      searchResults = [];
                    });
                  },
                  child:Container(
                    padding: const EdgeInsets.symmetric(horizontal:16, vertical:10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color:const Color(0xFFE85D26)),
                    ),
                    child: Text(item),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              ingredients.isEmpty
                ? 'No Ingredients added yet'
                : 'Your Pantry: ${ingredients.join(', ')}',
              style:const TextStyle(fontSize: 16, color:Colors.green),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeSearchScreen(
                      appliances: widget.appliances,
                      ingredients: ingredients,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D26),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          ],
        ),
      ),
    ); 
  }
}

class RecipeSearchScreen extends StatelessWidget {
  final List<String> appliances;
  final List<String> ingredients;

  const RecipeSearchScreen({
    super.key,
    required this.appliances,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Find Recipes'),
        backgroundColor: const Color(0xFFE85D26),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appliances: ${appliances.join(', ')}'),
            const SizedBox(height: 8),
            Text('Ingredients: ${ingredients.join(', ')}'),
          ],
        ),
      ),
    );
  }
}