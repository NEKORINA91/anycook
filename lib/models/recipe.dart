class Recipe {
  final String name;
  final List<String> requiredAppliances;
  final List<String> requiredIngredients;
  final int timeMinutes;

  const Recipe({
    required this.name,
    required this.requiredAppliances,
    required this.requiredIngredients,
    required this.timeMinutes,
  });

  // Later: a method here will compare this recipe's requirements
  // against the user's selected appliances/pantry and return
  // green / yellow / red — that's the Adaptive Filter logic.
}