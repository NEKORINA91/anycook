import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const AnyCookApp(),
    ),
  );
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
      home: const LoginScreen(),
    );
  }
}