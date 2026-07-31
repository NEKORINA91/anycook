import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/discovery_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🍳', style: TextStyle(fontSize: 70)),
              const SizedBox(height: 16),
              const Text(
                'AnyCook',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFE85D26)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to save your kitchen setup',
                style: TextStyle(color: Color(0xFF888888)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AppState>().logIn();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE85D26),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.read<AppState>().skipLogin();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
                  );
                },
                child: const Text('Skip for now', style: TextStyle(color: Color(0xFF888888))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}