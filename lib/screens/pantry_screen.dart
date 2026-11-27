import 'package:flutter/material.dart';
import 'package:anycook/screens/kitchen_setup_screen.dart';

/// The pantry now lives on the My kitchen page together with appliances.
/// Kept so older navigation code that opens PantryScreen still works.
class PantryScreen extends StatelessWidget {
  const PantryScreen({super.key});

  @override
  Widget build(BuildContext context) => const KitchenSetupScreen();
}
