import 'package:anycook/models/recipe.dart';

final List<Recipe> sampleRecipes = [
  const Recipe(
    name: 'Simple Cake',
    requiredAppliances: ['Oven'],
    requiredIngredients: ['Flour', 'Eggs', 'Sugar', 'Butter', 'Milk'],
    timeMinutes: 45,
    creatorName: 'Chef Amara',
    rating: 4.5,
    ratingCount: 128,
    photoUrls: ['placeholder1', 'placeholder2'],
    ingredientDetails: [
      Ingredient(name: 'flour', amount: 250, unit: 'g'),
      Ingredient(name: 'eggs', amount: 3, unit: 'pcs'),
      Ingredient(name: 'sugar', amount: 200, unit: 'g'),
      Ingredient(name: 'butter', amount: 100, unit: 'g'),
      Ingredient(name: 'milk', amount: 150, unit: 'ml'),
    ],
    steps: [
      RecipeStep(title: 'Preheat', description: 'Preheat your oven to 180°C (350°F).'),
      RecipeStep(title: 'Mix dry ingredients', description: 'Combine flour and sugar in a large bowl.'),
      RecipeStep(title: 'Add wet ingredients', description: 'Beat in eggs, melted butter, and milk until smooth.'),
      RecipeStep(title: 'Bake', description: 'Pour into a greased pan and bake for 35–40 minutes.'),
    ],
  ),
  const Recipe(
    name: 'Fried Rice',
    requiredAppliances: ['Stovetop'],
    requiredIngredients: ['Rice', 'Egg', 'Onion', 'Garlic', 'Oil'],
    timeMinutes: 20,
  ),
  const Recipe(
    name: 'Grilled Cheese',
    requiredAppliances: ['Stovetop'],
    requiredIngredients: ['Bread', 'Cheese', 'Butter'],
    timeMinutes: 10,
  ),
  const Recipe(
    name: 'Chicken Curry',
    requiredAppliances: ['Stovetop'],
    requiredIngredients: ['Chicken', 'Onion', 'Garlic', 'Ginger', 'Tomato', 'Oil'],
    timeMinutes: 35,
  ),

  const Recipe(
    name: 'Buttered Toast',
    requiredAppliances: ['Stovetop'],
    requiredIngredients: ['Bread', 'Butter'],
    timeMinutes: 5,
  ),

  
];
