// Fichier : lib/screens/home/favorite_parishes_screen.dart

import 'package:flutter/material.dart';
import '../../services/favorite_service.dart';
import '../../app_themes.dart';
import '../widgets/modern_card.dart';

class FavoriteParishesScreen extends StatefulWidget {
  const FavoriteParishesScreen({super.key});

  @override
  State<FavoriteParishesScreen> createState() => _FavoriteParishesScreenState();
}

class _FavoriteParishesScreenState extends State<FavoriteParishesScreen> {
  late Future<List<Map<String, String>>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = FavoriteService.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Mes Paroisses Favorites', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<Map<String, String>>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement des favoris.'));
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Vous n\'avez pas encore ajouté de paroisse à vos favoris.\n\nCliquez sur l\'étoile à côté d\'une paroisse dans le formulaire de demande pour en ajouter une.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              // ✅ MODIFIÉ : On récupère maintenant les 3 informations
              final parishName = favorite['nom'] ?? 'Nom inconnu';
              final communeName = favorite['commune'] ?? 'Commune inconnue';
              final cityName = favorite['ville'] ?? 'Ville inconnue';

              return ModernCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.church, color: AppTheme.primaryColor),
                  title: Text(parishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  // ✅ MODIFIÉ : On affiche la commune ET la ville pour plus de clarté
                  subtitle: Text('$communeName, $cityName'),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: AppTheme.warningColor),
                    tooltip: 'Retirer des favoris',
                    onPressed: () async {
                      // ✅ MODIFIÉ : On appelle removeFavorite avec les 3 paramètres nommés requis
                      await FavoriteService.removeFavorite(
                        ville: cityName,
                        commune: communeName,
                        nom: parishName,
                      );
                      // On rafraîchit la liste après la suppression
                      _loadFavorites();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}