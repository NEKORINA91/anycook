enum MatchTier { green, yellow, red }

enum MeasurementUnit { metric, imperial } // kg/g vs lb/oz, ml/l vs cups/tsp

class Ingredient {
  final String name;
  final double amount;
  final String unit; // 'g', 'kg', 'oz', 'lb', 'tsp', 'tbsp', 'ml', 'l', 'cup', 'pcs'

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  // Converts this ingredient's amount/unit to the user's preferred system.
  // Placeholder rules for now — good enough for display, refine later
  // with a proper conversion table once real recipes have varied units.
  Ingredient convertedTo(MeasurementUnit target) {
    const gToOz = 0.035274;
    const ozToG = 28.3495;
    const kgToLb = 2.20462;
    const lbToKg = 0.453592;

    if (target == MeasurementUnit.imperial) {
      if (unit == 'g') return Ingredient(name: name, amount: amount * gToOz, unit: 'oz');
      if (unit == 'kg') return Ingredient(name: name, amount: amount * kgToLb, unit: 'lb');
    } else {
      if (unit == 'oz') return Ingredient(name: name, amount: amount * ozToG, unit: 'g');
      if (unit == 'lb') return Ingredient(name: name, amount: amount * lbToKg, unit: 'kg');
    }
    return this; // already in target system, or a unit we don't convert (pcs, tsp, etc.)
  }

  String get display => '${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(1)} $unit $name';
}

class RecipeStep {
  final String title;
  final String description;

  const RecipeStep({required this.title, required this.description});
}

class Recipe {
  final String name;
  final List<String> requiredAppliances;
  final List<String> requiredIngredients; // names only, used by existing matching logic
  final int timeMinutes;

  // New fields for the detail page — all optional so old sample data still works.
  final List<Ingredient> ingredientDetails;
  final List<RecipeStep> steps;
  final List<String> photoUrls;
  final String? videoUrl;
  final double rating; // 0–5, average of all ratings. 0 = unrated.
  final int ratingCount;
  final String creatorName;

  const Recipe({
    required this.name,
    required this.requiredAppliances,
    required this.requiredIngredients,
    required this.timeMinutes,
    this.ingredientDetails = const [],
    this.steps = const [],
    this.photoUrls = const [],
    this.videoUrl,
    this.rating = 0,
    this.ratingCount = 0,
    this.creatorName = 'Unknown Chef',
  });

  bool hasRequiredAppliances(List<String> userAppliances) {
    return requiredAppliances.every((a) => userAppliances.contains(a));
  }

  List<String> missingIngredients(List<String> userIngredients) {
    return requiredIngredients
        .where((i) => !userIngredients.contains(i))
        .toList();
  }

  MatchTier matchTier(List<String> userIngredients) {
    final missingCount = missingIngredients(userIngredients).length;
    if (missingCount == 0) return MatchTier.green;
    if (missingCount <= 2) return MatchTier.yellow;
    return MatchTier.red;
  }
}

// ---------------------------------------------------------------------------
// Gamification — Chef Rank
// ---------------------------------------------------------------------------

enum ChefRank {
  tasteTester,
  homeCook,
  sousChef,
  headChef;

  String get displayName {
    switch (this) {
      case ChefRank.tasteTester:
        return 'Taste Tester';
      case ChefRank.homeCook:
        return 'Home Cook';
      case ChefRank.sousChef:
        return 'Sous Chef';
      case ChefRank.headChef:
        return 'Head Chef';
    }
  }

  String get emoji {
    switch (this) {
      case ChefRank.tasteTester:
        return '🥄';
      case ChefRank.homeCook:
        return '🍳';
      case ChefRank.sousChef:
        return '👨‍🍳';
      case ChefRank.headChef:
        return '⭐';
    }
  }
}

/// Pure function: maps a numeric score to a [ChefRank].
/// Thresholds: 0 → Taste Tester, 100 → Home Cook, 500 → Sous Chef, 2000 → Head Chef.
ChefRank chefRankFromScore(int score) {
  if (score >= 2000) return ChefRank.headChef;
  if (score >= 500) return ChefRank.sousChef;
  if (score >= 100) return ChefRank.homeCook;
  return ChefRank.tasteTester;
}

/// Returns the score threshold for the rank above the current one.
/// If already Head Chef, returns the Head Chef threshold (2000).
int nextRankThreshold(int score) {
  if (score >= 2000) return 2000;
  if (score >= 500) return 2000;
  if (score >= 100) return 500;
  return 100;
}

/// Returns the score threshold for the current rank (the floor).
int currentRankThreshold(int score) {
  if (score >= 2000) return 2000;
  if (score >= 500) return 500;
  if (score >= 100) return 100;
  return 0;
}