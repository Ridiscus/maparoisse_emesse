import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../app_themes.dart'; // Assure-toi que le chemin est correct
import 'dart:io'; // Pour vérifier la plateforme (iOS/Android)
import 'package:url_launcher/url_launcher.dart'; // Pour ouvrir les cartes
import 'package:provider/provider.dart';
import '../../services/auth_service.dart'; // <-- AJOUT


class ParishDetailScreen extends StatefulWidget {
  final Map<String, dynamic> parishData;

  const ParishDetailScreen({super.key, required this.parishData});

  @override
  State<ParishDetailScreen> createState() => _ParishDetailScreenState();
}

class _ParishDetailScreenState extends State<ParishDetailScreen> {
  // --- Variables d'état ---
  bool _isFavorite = false; // L'état actuel du favori
  bool _isLoadingFavorite = true; // Pour afficher un loader sur le bouton

  // --- Variables pour les données ---
  late String name;
  late String imageUrl;
  late String description;
  late String location;
  late String ville;
  late String commune;
  late int parishId;
  late double montantUnitaire;

  // Couleur ocre/dorée pour les éléments stylisés
  final Color ocreColor = AppTheme.primaryColor; // Utilise la couleur du thème

  @override
  void initState() {
    super.initState();
    _parseData(); // Extrait et prépare les données
    _checkFavoriteStatus(); // Vérifie si la paroisse est déjà en favori
  }

// DANS LA CLASSE _ParishDetailScreenState
// DANS LA CLASSE _ParishDetailScreenState

  void _parseData() {
    final l10n = AppLocalizations.of(context)!;

    // 1. Récupère les données de base
    name = widget.parishData['name'] ?? l10n.unknownParish;
    description = widget.parishData['description'] ?? l10n.descriptionUnavailable;
    parishId = widget.parishData['id'] ?? 0;

    // --- 2. CORRECTION GESTION IMAGE (Logique de nettoyage agressive) ---
    String? imgPath = widget.parishData['profile_picture'];

    if (imgPath != null && imgPath.isNotEmpty) {

      if (imgPath.startsWith('http')) {
        imageUrl = imgPath; // C'est déjà une URL complète
      }
      else {
        // --- CORRECTION DÉFINITIVE ---
        // 1. Enlève "/storage/paroisses/"
        if (imgPath.startsWith('/storage/paroisses/')) {
          imgPath = imgPath.substring(19);
        }
        // 2. Enlève "/paroisses/"
        else if (imgPath.startsWith('/paroisses/')) {
          imgPath = imgPath.substring(10);
        }
        // 3. Enlève "/storage/"
        else if (imgPath.startsWith('/storage/')) {
          imgPath = imgPath.substring(8);
        }
        // 4. Enlève le "/" au début
        else if (imgPath.startsWith('/')) {
          imgPath = imgPath.substring(1);
        }

        // 5. Reconstruit l'URL PROPRE
        imageUrl = "https://e-messe-ci.com/storage/" + imgPath;
        print("URL Paroisse Détail: $imageUrl"); // Pour déboguer
        // --- FIN CORRECTION ---
      }

    } else {
      imageUrl = 'assets/images/image_preview.jpg'; // Ton placeholder
    }
    // --- FIN CORRECTION IMAGE ---

    // --- 3. LOGIQUE VILLE/COMMUNE (INTELLIGENTE) ---
    var communeData = widget.parishData['commune'];

    if (communeData is Map) {
      // Cas A: Structure Imbriquée (vient des Favoris)
      // { "commune": { "nom_commune": "...", "ville": { "nom_ville": "..." } } }
      ville = communeData['ville']?['nom_ville'] ?? '';
      commune = communeData['nom_commune'] ?? '';
    }
    else if (communeData is String) {
      // Cas B: Structure Plate (vient de ParishScreen /paroisses)
      // { "commune": "Cocody", "ville": "Abidjan" }
      ville = widget.parishData['ville'] ?? '';
      commune = communeData;
    }
    else {
      // Cas C: Fallback (si 'commune' est null ou d'un autre type)
      ville = widget.parishData['ville'] ?? ''; // Essaye de lire 'ville' au cas où
      commune = '';
    }
    // --- FIN LOGIQUE ---


    // 4. Reconstruire la chaîne 'location' pour l'affichage
    if (ville.isNotEmpty && commune.isNotEmpty && ville != commune) {
      location = "$commune, $ville"; // Ex: "Cocody, Abidjan"
    } else if (commune.isNotEmpty) {
      location = commune;
    } else if (ville.isNotEmpty) {
      location = ville;
    } else {
      location = "Lieu inconnu";
    }


    // --- 5. AJOUT : RÉCUPÈRE LE MONTANT ---
    final dynamic rawAmount = widget.parishData['montant_unitaire'];
    double parsedAmount = 0.0; // Montant par défaut

    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    montantUnitaire = parsedAmount;
    // --- FIN AJOUT ---

  }



  /// --- MODIFIÉ : Vérifie via l'API ---
  /// --- RÉTABLIR CETTE FONCTION ---
  Future<void> _checkFavoriteStatus() async {
    // Si on n'a pas d'ID, on ne peut pas vérifier
    if (parishId == 0) {
      // Lit la valeur de la liste (qui peut être obsolète, mais c'est mieux que rien)
      setState(() {
        _isFavorite = widget.parishData['is_favori'] ?? false;
        _isLoadingFavorite = false;
      });
      return;
    }

    // Appelle l'API pour avoir l'état le plus récent
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final isFav = await authService.isParishFavorite(parishId);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _isLoadingFavorite = false;
        });
      }
    } catch (e) {
      // En cas d'erreur de l'API check, on se fie à ce que la liste disait
      if (mounted) {
        setState(() {
          _isFavorite = widget.parishData['is_favori'] ?? false;
          _isLoadingFavorite = false;
        });
      }
    }
  }
  // --- FIN RÉTABLISSEMENT ---



  Future<void> _toggleFavorite() async {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingFavorite || parishId == 0) return;

    setState(() => _isLoadingFavorite = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      bool success = await authService.toggleParishFavorite(parishId);

      if (success) {
        // 1. Récupère la hauteur pour le positionnement
        final double screenHeight = MediaQuery.of(context).size.height;

        if (mounted) {
          setState(() {
            _isFavorite = !_isFavorite; // Inverse l'état local

            // 2. Affiche le SnackBar en haut
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    // Icône dynamique : Cœur plein ou vide
                    Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isFavorite
                          ? l10n.parishAddedFavorite
                          : l10n.parishRemovedFavorite,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                // Couleur dynamique : Vert (Succès) ou Gris foncé (Neutre)
                backgroundColor: _isFavorite ? AppTheme.successColor : Colors.grey[800],

                behavior: SnackBarBehavior.floating, // OBLIGATOIRE pour le margin
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                // Positionnement en haut
                margin: EdgeInsets.only(
                    bottom: screenHeight - 165,
                    left: 20,
                    right: 20
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          });
        }
      } else {
        _showTopError(l10n.favoritesUpdateError);
      }
    } catch (e) {
      print("Erreur _toggleFavorite: $e");
      _showTopError(l10n.favoritesUpdateError);
    } finally {
      if (mounted) setState(() => _isLoadingFavorite = false);
    }
  }

  // Petit helper pour afficher les erreurs en haut aussi (pour être cohérent)
  void _showTopError(String message) {
    if (!mounted) return;
    final double screenHeight = MediaQuery.of(context).size.height;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Text(message),
        ]),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(bottom: screenHeight - 165, left: 20, right: 20),
      ),
    );
  }


  /// --- LOGIQUE POUR LE BOUTON MAPS (GOAL 2) ---

  Future<void> _launchMaps() async {
    final l10n = AppLocalizations.of(context)!;

    // Utilise la chaîne de localisation pour créer une requête de recherche
    final query = Uri.encodeComponent(location);

    // URL universelle pour Google Maps
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    // URL universelle pour Apple Maps
    final appleMapsUrl = Uri.parse("https://maps.apple.com/?q=$query");

    try {
      if (Platform.isIOS) { // Si c'est un iPhone
        if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl);
        } else if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl); // Ouvre Google Maps si Apple Maps n'est pas dispo
        }
      } else { // Si c'est Android (ou autre)
        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl);
        } else if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl);
        }
      }
    } catch (e) {
      print("Erreur _launchMaps: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.mapsOpenError))
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Détermine l'ImageProvider
    final ImageProvider displayImage;
    if (imageUrl.startsWith('http')) {
      displayImage = NetworkImage(imageUrl);
    } else {
      displayImage = AssetImage(imageUrl); // Pour le placeholder local
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          name, // Utilise la variable d'état
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Grande Image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: Image( // Utilise le widget Image pour gérer les deux types
                  image: displayImage,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. Conteneur stylisé
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: ocreColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: ocreColor.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      name.toUpperCase(), // Utilise la variable d'état
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ocreColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      description, // Utilise la variable d'état
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- EXEMPLE D'AFFICHAGE ---
                    Text(
                      l10n.offeringSuggested,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: ocreColor,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      // Formatte le montant
                      NumberFormat.decimalPattern('fr_FR').format(montantUnitaire) + " FCFA",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    // --- FIN EXEMPLE ---

                    const SizedBox(height: 16,),
                    // Ligne avec Localisation et Bouton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Chip Localisation
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
                              const SizedBox(width: 4),
                              Text(
                                location, // Utilise la variable d'état
                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),
                              ),
                            ],
                          ),
                        ),

                        // --- MODIFICATION GOAL 2 ---
                        // Bouton Plus de détails
                        ElevatedButton(
                          onPressed: _launchMaps, // Appelle la fonction maps
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ocreColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(l10n.moreDetailsButton),
                        ),
                        // --- FIN MODIFICATION ---
                      ],
                    ),

                    // --- AJOUT GOAL 1 : Bouton Favoris ---
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isLoadingFavorite ? null : _toggleFavorite,
                      icon: _isLoadingFavorite
                          ? Container( // Affiche un loader pendant la sauvegarde
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ocreColor,
                        ),
                      )
                          : Icon(
                        // Logique INVERSÉE (comme tu l'as demandée)
                        _isFavorite ? Icons.star : Icons.star_border,
                        color: ocreColor,
                        size: 20,
                      ),
                      label: Text(
                        // Texte conditionnel
                        _isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
                        style: TextStyle(color: ocreColor, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ocreColor,
                        side: BorderSide(color: ocreColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),

                        minimumSize: const Size(double.infinity, 44), // Prend toute la largeur
                      ),
                    ),
                    // --- FIN AJOUT ---
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}