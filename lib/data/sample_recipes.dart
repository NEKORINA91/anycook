import 'package:anycook/models/recipe.dart';

final List<Recipe> sampleRecipes = [
  const Recipe(
    name: 'Simple Cake',
    requiredAppliances: ['Oven'],
    requiredIngredients: ['Flour', 'Eggs', 'Sugar', 'Butter', 'Milk'],
    timeMinutes: 45,
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
