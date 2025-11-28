// lib/utils/navigation_state.dart
import 'package:flutter/foundation.dart';

// Notifier pour l'index du BottomNavigationBar (TU L'AS PROBABLEMENT DÉJÀ)
// Si tu n'en as pas, crée-le :
final ValueNotifier<int> bottomNavIndex = ValueNotifier(0); // 0 = HomeScreen

// Notifier SPÉCIFIQUE pour le filtre initial des demandes
// La valeur sera 'en attente', 'célébré', ou 'a venir' (ou null)
final ValueNotifier<String?> initialRequestListFilter = ValueNotifier(null);