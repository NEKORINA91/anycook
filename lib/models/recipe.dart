enum MatchTier { green, yellow, red }

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

  // Hard filter: user must have every appliance this recipe needs.
  bool hasRequiredAppliances(List<String> userAppliances) {
    return requiredAppliances.every((a) => userAppliances.contains(a));
  }

  // Which ingredients is the user missing for this recipe?
  List<String> missingIngredients(List<String> userIngredients) {
    return requiredIngredients
        .where((i) => !userIngredients.contains(i))
        .toList();
  }

  // Soft filter: how close is the user to having everything?
  MatchTier matchTier(List<String> userIngredients) {
    final missingCount = missingIngredients(userIngredients).length;
    if (missingCount == 0) return MatchTier.green;
    if (missingCount <= 2) return MatchTier.yellow;
    return MatchTier.red;
  }
}