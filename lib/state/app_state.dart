import 'package:flutter/material.dart';
import 'package:anycook/models/recipe.dart';
import 'package:anycook/data/sample_recipes.dart';

class AppState extends ChangeNotifier {
  // ── Existing fields (unchanged API) ──────────────────────────────────────
  bool isLoggedIn = false;
  List<String> appliances = [];
  List<String> pantryIngredients = [];

  // ── Auth / identity ──────────────────────────────────────────────────────
  String _username = 'Guest';
  String get username => _username;

  // ⚠️  LOCAL-ONLY MOCK — plaintext password stored purely for the
  //     change-password UI demo.  When a real backend is built, replace this
  //     with proper hashed/server-side auth.  NEVER ship plaintext passwords.
  String _password = '';
  String get password => _password;

  String _email = ''; // captured at sign-up; never displayed elsewhere
  String get email => _email;

  // ── User-uploaded recipes ────────────────────────────────────────────────
  final List<Recipe> _userRecipes = [];
  List<Recipe> get userRecipes => List.unmodifiable(_userRecipes);

  /// Combined view: sample data + anything the user uploaded this session.
  List<Recipe> get allRecipes => [...sampleRecipes, ..._userRecipes];

  void addUserRecipe(Recipe recipe) {
    _userRecipes.add(recipe);
    _chefScore += 50; // gamification: uploading a recipe earns points
    // Backend needed: persist recipe to database
    notifyListeners();
  }

  // ── Preferences ──────────────────────────────────────────────────────────
  MeasurementUnit _measurementUnit = MeasurementUnit.metric;
  MeasurementUnit get measurementUnit => _measurementUnit;
  void setMeasurementUnit(MeasurementUnit unit) {
    _measurementUnit = unit;
    notifyListeners();
  }

  bool _hideUnmakeableRecipes = false;
  bool get hideUnmakeableRecipes => _hideUnmakeableRecipes;
  void setHideUnmakeableRecipes(bool value) {
    _hideUnmakeableRecipes = value;
    notifyListeners();
  }

  // ── Search history ───────────────────────────────────────────────────────
  final List<String> _searchHistory = [];
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  void addSearchTerm(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;
    _searchHistory.remove(trimmed); // deduplicate
    _searchHistory.insert(0, trimmed); // most recent first
    if (_searchHistory.length > 10) _searchHistory.removeLast();
    notifyListeners();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  // ── Gamification ─────────────────────────────────────────────────────────
  int _chefScore = 0;
  int get chefScore => _chefScore;
  ChefRank get chefRank => chefRankFromScore(_chefScore);

  // ── Profile ──────────────────────────────────────────────────────────────
  String _bio = '';
  String get bio => _bio;

  String _location = '';
  String get location => _location;

  String? _profilePhotoUrl;
  String? get profilePhotoUrl => _profilePhotoUrl;

  void updateProfile({String? bio, String? location, String? photoUrl}) {
    if (bio != null) _bio = bio;
    if (location != null) _location = location;
    if (photoUrl != null) _profilePhotoUrl = photoUrl;
    // Backend needed: persist profile to database
    notifyListeners();
  }

  // ── Pantry helpers (were missing) ────────────────────────────────────────
  void addIngredient(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty || pantryIngredients.contains(trimmed)) return;
    pantryIngredients.add(trimmed);
    notifyListeners();
  }

  void removeIngredient(String ingredient) {
    pantryIngredients.remove(ingredient);
    notifyListeners();
  }

  // ── Auth methods ─────────────────────────────────────────────────────────

  /// Existing login — now also stores username.
  void logIn({String username = 'User'}) {
    isLoggedIn = true;
    _username = username;
    notifyListeners();
  }

  /// Existing guest/skip — unchanged semantics.
  void skipLogin() {
    isLoggedIn = false;
    _username = 'Guest';
    notifyListeners();
  }

  /// Login with credentials (local-only mock — no real auth).
  void loginWithUsername(String username, String password) {
    // ⚠️  LOCAL-ONLY MOCK — see password field note above.
    _username = username;
    _password = password;
    isLoggedIn = true;
    // Backend needed: validate credentials against server
    notifyListeners();
  }

  /// Sign-up (local-only mock).
  void signup(String username, String password, String email) {
    _username = username;
    _password = password; // ⚠️  LOCAL-ONLY MOCK
    _email = email;
    isLoggedIn = true;
    // Backend needed: create account on server, send verification email
    notifyListeners();
  }

  /// Change password (local-only mock validation).
  /// Returns true if old password matched and was changed, false otherwise.
  bool changePassword(String oldPassword, String newPassword) {
    // ⚠️  LOCAL-ONLY MOCK — real implementation needs server-side hashing.
    if (oldPassword != _password) return false;
    _password = newPassword;
    // Backend needed: update password hash on server
    notifyListeners();
    return true;
  }

  /// Log out — resets everything back to guest state.
  void logout() {
    isLoggedIn = false;
    _username = 'Guest';
    _password = '';
    _email = '';
    appliances = [];
    pantryIngredients = [];
    _userRecipes.clear();
    _measurementUnit = MeasurementUnit.metric;
    _hideUnmakeableRecipes = false;
    _searchHistory.clear();
    _chefScore = 0;
    _bio = '';
    _location = '';
    _profilePhotoUrl = null;
    notifyListeners();
  }

  // ── Existing ─────────────────────────────────────────────────────────────
  void setAppliances(List<String> selected) {
    appliances = selected;
    notifyListeners();
  }
}