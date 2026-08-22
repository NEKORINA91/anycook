import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/widgets/appliance_chip.dart';
import 'package:anycook/state/app_state.dart';

class KitchenSetupScreen extends StatefulWidget {
  const KitchenSetupScreen({super.key});

  @override
  State<KitchenSetupScreen> createState() => _KitchenSetupScreenState();
}

class _KitchenSetupScreenState extends State<KitchenSetupScreen> {
  late List<String> selectedAppliances;

  final List<String> allAppliances = [
    'Oven',
    'Microwave',
    'Air Fryer',
    'Stovetop',
    'Rice Cooker',
    'Blender',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with whatever's already saved, so re-opening this screen
    // shows your existing selection instead of starting blank.
    selectedAppliances = List.from(context.read<AppState>().appliances);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appliances'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE85D26),
        elevation: 0,
      ),
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
                      context.read<AppState>().setAppliances(selectedAppliances);
                      Navigator.pop(context);
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
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}