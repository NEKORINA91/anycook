import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:anycook/state/app_state.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/theme/app_theme.dart';
import 'package:anycook/widgets/ui.dart';

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

  final List<String> _photos = [];

  final List<String> _applianceOptions = [
    'Stovetop', 'Microwave', 'Kettle', 'Oven', 'Air Fryer', 'Rice Cooker', 'Blender', 'Toaster',
  ];

  @override
  void initState() {
    super.initState();
    // Keep the live preview in sync with what's typed.
    _titleController.addListener(_refresh);
    _timeController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

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
    final wide = isWide(context);
    final title = _titleController.text.trim();
    final time = _timeController.text.trim();

    Widget sectionTitle(String n, String t) =>
        Text('$n · $t', style: AppTheme.display(size: 22));

    final basics = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionTitle('1', 'The basics'),
          const SizedBox(height: 16),
          SplitLayout(
            breakpoint: 520,
            gap: 12,
            firstFlex: 3,
            secondFlex: 1,
            first: _Labeled(
              label: 'Recipe name',
              child: TextField(controller: _titleController, decoration: const InputDecoration(hintText: 'Microwave mug brownie')),
            ),
            second: _Labeled(
              label: 'Time (min)',
              child: TextField(
                controller: _timeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: '5'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Labeled(
            label: 'Short description (optional)',
            child: TextField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Rich, gooey and ready before the kettle boils'),
            ),
          ),
          const SizedBox(height: 14),
          Pressable(
            onTap: _addPhoto,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD6CEC5), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, color: AppColors.accent, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    _photos.isEmpty ? 'Add photos (up to 3)' : '${_photos.length} of 3 photos added. Tap to add another',
                    style: const TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _photos.length; i++)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _photos[i],
                          width: 96,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => SizedBox(
                            width: 96,
                            height: 72,
                            child: FoodArt(seed: 'photo$i', height: 72, radius: 12, iconSize: 22),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: IconButton(
                          tooltip: 'Remove photo',
                          onPressed: () => setState(() => _photos.removeAt(i)),
                          icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.ink),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            fixedSize: const Size(26, 26),
                            minimumSize: const Size(26, 26),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _addVideo,
              icon: const Icon(Icons.videocam_outlined, size: 18),
              label: const Text('Add a video'),
            ),
          ),
        ],
      ),
    );

    final appliances = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionTitle('2', 'Appliances needed'),
          const SizedBox(height: 6),
          const Text('Pick everything the recipe needs. Fewer appliances = more kitchens can make it.',
              style: TextStyle(fontSize: 14, color: AppColors.muted)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in _applianceOptions)
                FilterPill(
                  label: a,
                  selected: _selectedAppliances.contains(a),
                  onTap: () => setState(() {
                    if (_selectedAppliances.contains(a)) {
                      _selectedAppliances.remove(a);
                    } else {
                      _selectedAppliances.add(a);
                    }
                  }),
                ),
            ],
          ),
        ],
      ),
    );

    final ingredients = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionTitle('3', 'Ingredients'),
          const SizedBox(height: 14),
          for (var index = 0; index < _ingredients.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    child: TextField(
                      controller: _ingredients[index].amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: '2'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.lineStrong),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _ingredients[index].unit,
                        borderRadius: BorderRadius.circular(14),
                        items: [
                          for (final u in _unitOptions) DropdownMenuItem(value: u, child: Text(u)),
                        ],
                        onChanged: (v) => setState(() => _ingredients[index].unit = v ?? 'g'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ingredients[index].nameController,
                      decoration: const InputDecoration(hintText: 'Ingredient, like flour'),
                    ),
                  ),
                  if (_ingredients.length > 1)
                    IconButton(
                      tooltip: 'Remove ingredient',
                      icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                      onPressed: () {
                        final removed = _ingredients.removeAt(index);
                        setState(() {});
                        WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
                      },
                    ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _ingredients.add(_RecipeIngredient())),
              child: const Text('+ Add ingredient'),
            ),
          ),
        ],
      ),
    );

    final steps = SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          sectionTitle('4', 'Steps'),
          const SizedBox(height: 14),
          for (var index = 0; index < _steps.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: AppTheme.display(size: 30, weight: FontWeight.w300, color: AppColors.accent),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _steps[index].titleController,
                      minLines: 2,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: index == 0 ? 'Mix the dry ingredients in a large mug' : 'Describe the next step',
                      ),
                    ),
                  ),
                  if (_steps.length > 1)
                    IconButton(
                      tooltip: 'Remove step',
                      icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                      onPressed: () {
                        final removed = _steps.removeAt(index);
                        setState(() {});
                        WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
                      },
                    ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _steps.add(_RecipeStepData())),
              child: const Text('+ Add step'),
            ),
          ),
        ],
      ),
    );

    final preview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Eyebrow('Live preview'),
        const SizedBox(height: 12),
        SectionCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FoodArt(seed: title.isEmpty ? 'preview' : title, height: 180),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 14, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.isEmpty ? 'Your recipe name' : title,
                        style: AppTheme.display(size: 19, weight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    Text(
                      '${time.isEmpty ? '–' : time} min · '
                      '${_selectedAppliances.isEmpty ? 'Any kitchen' : _selectedAppliances.join(', ')} · by you',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          color: AppColors.lilac,
          borderColor: null,
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Recipes that only need a microwave or kettle reach the most kitchens.',
            style: TextStyle(fontSize: 14, height: 1.55, color: AppColors.lilacDeep),
          ),
        ),
      ],
    );

    return AppShell(
      current: NavTab.upload,
      body: PageWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: wide ? 24 : 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 16,
              runSpacing: 16,
              children: [
                const PageTitle('Share a recipe'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton(onPressed: () => showSoon(context, 'Saving drafts'), child: const Text('Save draft')),
                    FilledButton(onPressed: _saveRecipe, child: const Text('Publish')),
                  ],
                ),
              ],
            ),
            SizedBox(height: wide ? 32 : 20),
            SplitLayout(
              firstFlex: 2,
              secondFlex: 1,
              gap: 28,
              first: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  basics,
                  const SizedBox(height: 20),
                  appliances,
                  const SizedBox(height: 20),
                  ingredients,
                  const SizedBox(height: 20),
                  steps,
                ],
              ),
              second: preview,
            ),
          ],
        ),
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
