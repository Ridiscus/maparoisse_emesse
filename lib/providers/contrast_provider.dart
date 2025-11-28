// Fichier : lib/providers/contrast_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContrastProvider with ChangeNotifier {
  bool _isHighContrast = false;

  bool get isHighContrast => _isHighContrast;

  ContrastProvider() {
    _loadContrastSetting();
  }

  void _loadContrastSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isHighContrast = prefs.getBool('high_contrast') ?? false;
    notifyListeners();
  }

  void setHighContrast(bool isOn) async {
    if (_isHighContrast == isOn) return;

    _isHighContrast = isOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', isOn);
    notifyListeners();
  }
}