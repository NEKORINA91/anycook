import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/models/recipe.dart';

class RecipeUploadScreen extends StatefulWidget {
  const RecipeUploadScreen({super.key});

  @override
  State<RecipeUploadScreen> createState() => _RecipeUploadScreenState();
}

class _RecipeIngredient {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String unit = 'g';

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

class _RecipeStepData {
  final TextEditingController titleController = TextEditingController();

  void dispose() {
    titleController.dispose();
  }
}

class _RecipeUploadScreenState extends State<RecipeUploadScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  final List<_RecipeIngredient> _ingredients = [_RecipeIngredient()];
  final List<_RecipeStepData> _steps = [_RecipeStepData()];
  String _applianceSearch = '';

  final List<String> _photos = [];

  final List<String> _applianceOptions = [
    'Oven',
    'Microwave',
    'Air Fryer',
    'Stovetop',
    'Rice Cooker',
    'Blender'
  ];

  final List<String> _selectedAppliances = [];

  final List<String> _unitOptions = [
    'g', 'kg', 'ml', 'l', 'cups', 'tsp', 'tbsp', 'oz', 'lb', 'pcs'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    for (var ing in _ingredients) {
      ing.dispose();
    }
    for (var step in _steps) {
      step.dispose();
    }
    super.dispose();
  }

  void _addPhoto() {
    // Backend needed: image upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker coming soon')),
    );
    setState(() {
      if (_photos.length < 3) {
        _photos.add('https://picsum.photos/400/300?random=${_photos.length}');
      }
    });
  }

  void _addVideo() {
    // Backend needed: video upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video picker coming soon')),
    );
  }

  void _saveRecipe() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe title')),
      );
      return;
    }

    final validIngredients = _ingredients.where((i) => i.nameController.text.trim().isNotEmpty).toList();
    if (validIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    final validSteps = _steps.where((s) => s.titleController.text.trim().isNotEmpty).toList();
    if (validSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one step')),
      );
      return;
    }

    final appState = context.read<AppState>();
    
    List<Ingredient> finalIngredients = validIngredients.map((ing) {
      double amount = double.tryParse(ing.amountController.text.trim()) ?? 1.0;
      return Ingredient(
        name: ing.nameController.text.trim(),
        amount: amount,
        unit: ing.unit,
      );
    }).toList();

    List<RecipeStep> finalSteps = validSteps.map((step) {
      return RecipeStep(
        title: step.titleController.text.trim(),
        description: '', // Description is empty as per requirement
      );
    }).toList();

    int timeMins = int.tryParse(_timeController.text.trim()) ?? 30;

    final newRecipe = Recipe(
      name: _titleController.text.trim(),
      requiredAppliances: _selectedAppliances.toList(),
      requiredIngredients: finalIngredients.map((i) => i.name).toList(),
      timeMinutes: timeMins,
      ingredientDetails: finalIngredients,
      steps: finalSteps,
      photoUrls: _photos,
      videoUrl: null,
      rating: 0.0,
      ratingCount: 0,
      creatorName: appState.username,
    );

    // Backend needed: persist to database
    appState.addUserRecipe(newRecipe);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('Upload Recipe'),
        backgroundColor: const Color(0xFFE85D26),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_photos.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: _photos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(_photos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (_photos.isNotEmpty) const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    return GestureDetector(
                      onTap: _addPhoto,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.grey),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _addVideo,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_fill, color: Colors.grey, size: 40),
                          SizedBox(height: 8),
                          Text('Add Video', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Recipe Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Title *',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Cook Time (minutes)',
                    prefixIcon: Icon(Icons.timer),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Required Appliances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (query) => setState(() => _applianceSearch = query),
                  decoration: InputDecoration(
                    hintText: 'Search appliances...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                if (_selectedAppliances.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedAppliances.map((a) {
                      return Chip(
                        label: Text(a),
                        onDeleted: () => setState(() => _selectedAppliances.remove(a)),
                        backgroundColor: const Color(0xFFE85D26).withValues(alpha: 0.1),
                      );
                    }).toList(),
                  ),
                if (_applianceSearch.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _applianceOptions
                        .where((a) =>
                            a.toLowerCase().contains(_applianceSearch.toLowerCase()) &&
                            !_selectedAppliances.contains(a))
                        .map((a) {
                      return ActionChip(
                        label: Text(a),
                        onPressed: () => setState(() {
                          _selectedAppliances.add(a);
                          _applianceSearch = '';
                        }),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                const Text('Ingredients *', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._ingredients.asMap().entries.map((entry) {
                  int index = entry.key;
                  _RecipeIngredient ingredient = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: ingredient.nameController,
                            decoration: const InputDecoration(
                              hintText: 'Name',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: ingredient.amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: 'Amount',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButton<String>(
                            value: ingredient.unit,
                            underline: const SizedBox(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  ingredient.unit = newValue;
                                });
                              }
                            },
                            items: _unitOptions.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (_ingredients.length > 1) {
                                ingredient.dispose();
                                _ingredients.removeAt(index);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _ingredients.add(_RecipeIngredient());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ingredient'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE85D26),
                    side: const BorderSide(color: Color(0xFFE85D26)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Steps *', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  _RecipeStepData step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 14.0, right: 8.0),
                          child: Text(
                            'Step ${index + 1}:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: step.titleController,
                            decoration: const InputDecoration(
                              hintText: 'Step instruction',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (_steps.length > 1) {
                                step.dispose();
                                _steps.removeAt(index);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _steps.add(_RecipeStepData());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Step'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE85D26),
                    side: const BorderSide(color: Color(0xFFE85D26)),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE85D26),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Recipe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
