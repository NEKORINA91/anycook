import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/screens/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFE85D26),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Measurement Unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Metric'),
                    selected: appState.measurementUnit == MeasurementUnit.metric,
                    selectedColor: const Color(0xFFE85D26),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: appState.measurementUnit == MeasurementUnit.metric
                          ? Colors.white
                          : const Color(0xFF2B2B2B),
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        context.read<AppState>().setMeasurementUnit(MeasurementUnit.metric);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Imperial'),
                    selected: appState.measurementUnit == MeasurementUnit.imperial,
                    selectedColor: const Color(0xFFE85D26),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: appState.measurementUnit == MeasurementUnit.imperial
                          ? Colors.white
                          : const Color(0xFF2B2B2B),
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        context.read<AppState>().setMeasurementUnit(MeasurementUnit.imperial);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Hide recipes I can't make",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                subtitle: const Text(
                  "Hides recipes requiring appliances you don't have",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
                activeThumbColor: const Color(0xFFE85D26),
                value: appState.hideUnmakeableRecipes,
                onChanged: (value) {
                  context.read<AppState>().setHideUnmakeableRecipes(value);
                },
              ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Color(0xFFE85D26)),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
                onTap: () {
                  context.read<AppState>().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
