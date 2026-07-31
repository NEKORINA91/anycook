import 'package:flutter/material.dart';
import 'package:anycook/widgets/appliance_chip.dart';
import 'package:anycook/screens/pantry_screen.dart';

class KitchenSetupScreen extends StatefulWidget {
  const KitchenSetupScreen({super.key});

  @override
  State<KitchenSetupScreen> createState() => _KitchenSetupScreenState();
}

class _KitchenSetupScreenState extends State<KitchenSetupScreen> {
  List<String> selectedAppliances = [];

  final List<String> allAppliances = [
    'Oven',
    'Microwave',
    'Air Fryer',
    'Stovetop',
    'Rice Cooker',
    'Blender',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap what you have:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: allAppliances.map((appliance) {
                bool isSelected = selectedAppliances.contains(appliance);
                return SelectableChip(
                  label: appliance,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedAppliances.remove(appliance);
                      } else {
                        selectedAppliances.add(appliance);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Text(
              selectedAppliances.isEmpty
                  ? 'No appliances selected yet'
                  : 'Selected: ${selectedAppliances.join(', ')}',
              style: const TextStyle(fontSize: 16, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: selectedAppliances.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantryScreen(
                            appliances: selectedAppliances,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE85D26),
                disabledBackgroundColor: Colors.grey.shade300,
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