import 'dart:async'; // Nécessaire pour le Timer
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const THEME_KEY = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Timer pour vérifier l'heure régulièrement
  Timer? _timer;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // --- 1. LOGIQUE DE CHANGEMENT ---
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _saveThemeToPrefs(mode);

    // Si l'utilisateur choisit "Système", on active la vérification horaire personnalisée
    // (Ou tu peux créer un 4ème mode spécifique "AutoTime" si tu préfères ne pas toucher au mode Système natif)
    if (mode == ThemeMode.system) {
      _startAutoCheck();
    } else {
      _stopAutoCheck(); // On arrête de vérifier l'heure si l'utilisateur force Clair ou Sombre
    }

    notifyListeners();
  }

  // --- 2. VÉRIFICATION DE L'HEURE ---
  void _startAutoCheck() {
    // Vérifie tout de suite
    _checkTimeAndApply();

    // Puis vérifie toutes les minutes (pour changer pile à l'heure)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkTimeAndApply();
    });
  }

  void _stopAutoCheck() {
    _timer?.cancel();
  }

  void _checkTimeAndApply() {
    // Si on n'est pas en mode système, on ne fait rien
    if (_themeMode != ThemeMode.system) return;

    final hour = DateTime.now().hour;

    // Règle : Mode Nuit entre 19h (19) et 6h (6) du matin
    // Mode Jour le reste du temps
    bool isNightTime = hour >= 19 || hour < 6;

    // Note: Ici on ne change pas _themeMode (qui reste "System"),
    // Mais on devrait idéalement avoir une variable locale pour l'affichage.
    // CEPENDANT, pour simplifier avec Flutter :
    // Si tu veux forcer le visuel sans changer le réglage "System",
    // Flutter le fait déjà nativement si le téléphone est bien réglé.

    // Si tu veux FORCER ta propre logique par dessus le système :
    // On ne peut pas facilement dire à Flutter "Sois en System mais utilise ma logique".
    // Donc l'astuce est de créer une méthode qui retourne le Brightness.

    notifyListeners();
  }

  // --- Helper pour savoir si on doit afficher en sombre ---
  // Utilise cette fonction si tu veux ignorer le réglage du téléphone
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;

    // Si mode système, on applique TA logique d'heure
    final hour = DateTime.now().hour;
    return hour >= 19 || hour < 6;
  }

  // --- CHARGEMENT / SAUVEGARDE (inchangé) ---
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(THEME_KEY);

    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        _startAutoCheck(); // Lance la vérification auto
        break;
    }
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
        break;
    }
    await prefs.setString(THEME_KEY, themeString);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}