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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('My Kitchen'),
        backgroundColor: const Color(0xFFE85D26),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('', style: TextStyle(fontSize: 20),
        )
      )

    );
  }
} 