import 'package:flutter/material.dart';
import 'package:anycook/screens/home_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE85D26)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}