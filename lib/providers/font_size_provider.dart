// Fichier : lib/providers/font_size_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pour avoir des choix clairs et lisibles
enum FontSizeLevel { small, medium, large }

class FontSizeProvider with ChangeNotifier {
  FontSizeLevel _fontSizeLevel = FontSizeLevel.medium;

  FontSizeLevel get fontSizeLevel => _fontSizeLevel;

  // On associe un multiplicateur à chaque niveau
  double get multiplier {
    switch (_fontSizeLevel) {
      case FontSizeLevel.small:
        return 0.85;
      case FontSizeLevel.medium:
        return 1.0;
      case FontSizeLevel.large:
        return 1.2;
    }
  }

  FontSizeProvider() {
    _loadFontSize();
  }

  // Charge la préférence de l'utilisateur depuis la mémoire du téléphone
  void _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final levelIndex = prefs.getInt('font_size_level') ?? FontSizeLevel.medium.index;
    _fontSizeLevel = FontSizeLevel.values[levelIndex];
    notifyListeners();
  }

  // Modifie la taille, sauvegarde la préférence et notifie l'application
  void setFontSizeLevel(FontSizeLevel level) async {
    if (_fontSizeLevel == level) return;

    _fontSizeLevel = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('font_size_level', level.index);
    notifyListeners();
  }
}