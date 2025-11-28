// Fichier : lib/services/favorite_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  // On peut garder la même clé, la structure reste une liste de JSON.
  // L'application s'adaptera.
  static const _key = 'favoriteParishes_v2';

  /// Récupère la liste des favoris. Chaque favori est une Map.
  static Future<List<Map<String, String>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = prefs.getStringList(_key) ?? [];

    return favoritesJson
        .map((jsonString) => Map<String, String>.from(jsonDecode(jsonString)))
        .toList();
  }

  /// Sauvegarde la liste complète des favoris.
  static Future<void> _saveFavorites(List<Map<String, String>> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson =
    favorites.map((fav) => jsonEncode(fav)).toList();
    await prefs.setStringList(_key, favoritesJson);
  }

  /// ✅ MODIFIÉ : Ajoute une paroisse aux favoris avec sa ville et sa commune.
  static Future<void> addFavorite({
    required String ville,
    required String commune,
    required String nom,
  }) async {
    final favorites = await getFavorites();
    final newFavorite = {'ville': ville, 'commune': commune, 'nom': nom};

    // La vérification se fait maintenant sur les trois champs pour être certain de l'unicité.
    if (!favorites.any((fav) =>
    fav['nom'] == nom &&
        fav['commune'] == commune &&
        fav['ville'] == ville)) {
      favorites.add(newFavorite);
      await _saveFavorites(favorites);
    }
  }

  /// ✅ MODIFIÉ : Retire une paroisse des favoris en se basant sur son nom, sa commune et sa ville.
  static Future<void> removeFavorite({
    required String ville,
    required String commune,
    required String nom,
  }) async {
    final favorites = await getFavorites();
    favorites.removeWhere((fav) =>
    fav['nom'] == nom &&
        fav['commune'] == commune &&
        fav['ville'] == ville);
    await _saveFavorites(favorites);
  }

  /// ✅ MODIFIÉ : Vérifie si une paroisse spécifique est déjà dans les favoris.
  static Future<bool> isFavorite({
    required String ville,
    required String commune,
    required String nom,
  }) async {
    // Si une des infos manque, ce ne peut pas être un favori valide.
    if (ville.isEmpty || commune.isEmpty || nom.isEmpty) return false;

    final favorites = await getFavorites();
    return favorites.any((fav) =>
    fav['nom'] == nom &&
        fav['commune'] == commune &&
        fav['ville'] == ville);
  }
}