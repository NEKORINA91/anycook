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
        ],

      ),

    )
    );
  }
} 