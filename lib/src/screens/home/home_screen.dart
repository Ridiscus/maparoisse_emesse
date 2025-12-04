import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../app_themes.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maparoisse/src/screens/home/edit_profile_screen.dart';
import 'package:maparoisse/src/screens/home/notifications_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:collection/collection.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:maparoisse/src/screens/home/settings_screen.dart';
import 'package:maparoisse/src/screens/home/identification_screen.dart';
import 'package:in_app_update/in_app_update.dart';


class HomeScreen extends StatefulWidget {
  // Garde les callbacks si tu en as besoin pour la navigation depuis HomeScreen
  final VoidCallback? onNewRequest;
  // final VoidCallback? onGoToRequests;

  const HomeScreen({
    super.key,
    this.onNewRequest,
    // this.onGoToRequests,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String _userName = "Utilisateur";
  String? _userAvatarUrl;
  String _userLocation = "Abidjan, Yopougon"; // Placeholder

  // --- Données de l'API ---
  late AuthService _authService;
  List<dynamic> _allMassRequests = [];
  List<dynamic> _allParishes = [];


  // --- Données filtrées pour l'UI ---
  int _pendingCount = 0;
  int _celebratedCount = 0;
  int _upcomingCount = 0;
  List<dynamic> _upcomingMasses = []; // Contiendra les messes "confirmées"

  final Color _ocreColor = const Color(0xFFC0A040); // Couleur dorée/ocre
  final Color _greenColor = AppTheme.successColor; // Vert
  final Color _blueColor = AppTheme.infoColor; // Bleu

  // --- Variables pour la localisation ---
  Position? _currentPosition; // Stocke les coordonnées GPS
  String _displayLocation = ""; // Texte à afficher
  bool _isFetchingLocation = false; // Pour l'indicateur de chargement

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadData();
    // On lance la récupération de la localisation après le chargement initial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });

    // Vérification de la mise à jour après un petit délai pour ne pas bloquer l'UI au démarrage
    Future.delayed(const Duration(seconds: 2), () {
      _checkForUpdate();
    });

  }




  // --- GESTION DES MISES À JOUR (Google Play) ---
  Future<void> _checkForUpdate() async {
    try {
      // 1. Vérifier s'il y a une mise à jour disponible
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {

        // OPTION A : MISE À JOUR IMMÉDIATE (Bloquante - Recommandée pour ton lancement)
        // L'utilisateur DOIT mettre à jour pour continuer.
        await InAppUpdate.performImmediateUpdate();

        /* // OPTION B : MISE À JOUR FLEXIBLE (Non bloquante)
        // Télécharge en fond, puis demande à l'utilisateur de redémarrer.
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
        */
      }
    } catch (e) {
      print("Erreur InAppUpdate: $e");
      // Ne rien faire, laisser l'utilisateur utiliser l'appli normalement
    }
  }



  Future<void> _getCurrentLocation() async {
    // 1. Récupère les traductions
    final l10n = AppLocalizations.of(context)!;

    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isFetchingLocation = true);

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // ✅ TRADUCTION
        setState(() => _displayLocation = l10n.homeLocationDisabled);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // ✅ TRADUCTION
          setState(() => _displayLocation = l10n.homeLocationDenied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // ✅ TRADUCTION
        setState(() => _displayLocation = l10n.homeLocationBlocked);
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);

      if (_currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks[0];
          String subLocality = place.subLocality ?? '';
          String city = place.locality ?? '';

          // (Ta logique de construction d'adresse reste inchangée ici)
          if (subLocality.isNotEmpty && city.isNotEmpty) {
            _displayLocation = "$subLocality, $city";
          } else if (city.isNotEmpty) {
            _displayLocation = city;
          } else {
            // Fallback générique
            _displayLocation = place.street ?? place.country ?? l10n.homeLocationUnknown;
          }

        } else {
          // ✅ TRADUCTION
          _displayLocation = l10n.homeLocationNotFound;
        }
      } else {
        // ✅ TRADUCTION
        _displayLocation = l10n.homeLocationPosNotFound;
      }

    } catch (e) {
      print("Erreur _getCurrentLocation: $e");
      // ✅ TRADUCTION
      _displayLocation = l10n.homeLocationError;
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
  }


  // --- Nouvelle fonction pour ouvrir la carte ---
  Future<void> _openMap() async {
    if (_currentPosition == null) return;

    // Crée l'URL pour Google Maps (ou Apple Maps sur iOS)
    final latitude = _currentPosition!.latitude;
    final longitude = _currentPosition!.longitude;
    // Utilise geo: pour une intention générique ou des URL spécifiques
    // Google Maps URL
    final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
    // Apple Maps URL (fallback)
    // final appleMapsUrl = Uri.parse("https://maps.apple.com/?q=$latitude,$longitude");


    // Lance l'URL
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      // Fallback ou message d'erreur si aucune app de carte n'est trouvée
      print("Impossible d'ouvrir l'application de carte.");
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.homeMapError))
        );
      }
    }
  }



  // MODIFIÉ : Ajout du paramètre optionnel {bool isRefresh = false}
  Future<void> _loadData({bool isRefresh = false}) async {

    // On affiche le gros loader SEULEMENT si ce n'est pas un rafraîchissement manuel
    if (!isRefresh) {
      setState(() => _loading = true);
    }

    try {
      // 1. Infos Utilisateur (Ton code inchangé)
      if (_authService.isAuthenticated) {
        _userName = _authService.fullName ?? "Utilisateur";
        _userAvatarUrl = _authService.photoPath;
      }

      // 2. Charge les données API (Ton code inchangé)
      final requestsFuture = _authService.getMassRequests();
      final parishesFuture = _authService.getParishes();

      final results = await Future.wait([requestsFuture, parishesFuture]);

      // Mise à jour des variables
      if (mounted) {
        setState(() {
          _allMassRequests = results[0] as List<dynamic>;
          _allParishes = results[1] as List<dynamic>;

          // 3. APPEL UNIQUE DU CALCUL (Ton code inchangé)
          _calculateCounts();
        });
      }

    } catch (e) {
      print("Erreur _loadData HomeScreen: $e");
      // Optionnel : Afficher un petit message d'erreur discret si le refresh échoue
      if (mounted && isRefresh) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur d'actualisation"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        // On arrête le loader (qu'il soit gros ou petit)
        setState(() => _loading = false);
      }
    }
  }




  Future<void> _handleRefresh() async {
    // Appel avec isRefresh: true pour ne pas cacher l'écran
    await _loadData(isRefresh: true);
  }




  // Fonction de parsing robuste
  DateTime _parseDateRobust(String? dateStr) {
    if (dateStr == null) return DateTime(1900);
    try { return DateTime.parse(dateStr); }
    catch (e) {
      print("Date non reconnue (HomeScreen): $dateStr");
      return DateTime(1900);
    }
  }


  /// Helper pour trouver le nom de la paroisse
  String _findParishName(int parishId) {
    final parish = _allParishes.firstWhereOrNull((p) => p['id'] == parishId);
    return parish?['name'] ?? 'Paroisse inconnue';
  }



  void _calculateCounts() {
    int pending = 0;
    int celebrated = 0;

    // Liste temporaire pour les messes à venir
    List<dynamic> upcomingList = [];

    for (var mass in _allMassRequests) {
      // 1. Nettoyage des données
      String statusRaw = (mass['statut'] ?? '').toString();
      String status = statusRaw.toLowerCase().trim();

      // Vérification Paiement (Sécurité supplémentaire)
      List<dynamic> paiements = mass['paiements'] ?? [];
      bool isPaid = paiements.isNotEmpty &&
          (paiements[0]['statut'] == 'paye' || paiements[0]['statut'] == 'confirmee');

      // --- LOGIQUE DE TRI STRICTE ---

      // CAS 1 : EN ATTENTE DE PAIEMENT (Carte Jaune)
      if (status == 'en_attente_paiement') {
        pending++;
      }

      // CAS 2 : CÉLÉBRÉES (Carte Verte)
      else if (status.contains('celebre')) {
        celebrated++;
      }

      // CAS 3 : ANNULÉES (On ignore totalement)
      else if (status.contains('annul')) {
        continue; // On passe au suivant, on ne compte pas
      }

      // CAS 4 : À VENIR (Carte Bleue)
      // C'est ici qu'on applique la règle stricte
      else {
        // Conditions pour être "À venir" :
        // 1. Soit c'est confirmé
        // 2. Soit c'est "en attente" (avec espace = payé, attente validation)
        // 3. Soit le paiement est marqué comme fait (isPaid)

        bool isConfirmed = status.contains('confirm');
        bool isWaitingValidation = status == 'en attente'; // Attention à l'espace !

        if (isConfirmed || isWaitingValidation || isPaid) {
          upcomingList.add(mass);
        }
      }
    }

    // Tri par date (la plus proche en premier)
    upcomingList.sort((a, b) =>
        _parseDateRobust(a['date_souhaitee']).compareTo(_parseDateRobust(b['date_souhaitee']))
    );

    // Mise à jour de l'interface
    if (mounted) {
      setState(() {
        _pendingCount = pending;
        _celebratedCount = celebrated;

        // Mise à jour synchronisée du compteur ET de la liste
        _upcomingCount = upcomingList.length;
        _upcomingMasses = upcomingList;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    // On utilise le thème pour les couleurs de fond
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        // 1. GESTION DU CHARGEMENT INITIAL
        // Si c'est le tout premier chargement (_loading est true), on affiche le rond au centre.
        // Sinon, on affiche l'interface avec le RefreshIndicator.
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFC0A040)))
            : RefreshIndicator(
          // 2. GESTION DU RAFRAÎCHISSEMENT
          onRefresh: _handleRefresh,
          color: const Color(0xFFC0A040), // Couleur Ocre
          backgroundColor: theme.cardTheme.color, // Fond du rond adapté au mode sombre

          child: SingleChildScrollView(
            // 3. PHYSIQUE DU SCROLL (CRUCIAL)
            // Cette ligne permet de "tirer" l'écran même s'il y a peu de contenu
            physics: const AlwaysScrollableScrollPhysics(),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Ton padding d'origine
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16), // Espace en haut

                  // Tes widgets existants
                  _buildAppBarContent(context),
                  const SizedBox(height: 24),

                  _buildStatusSection(context),
                  const SizedBox(height: 24),

                  _buildNextMassesSection(context),
                  const SizedBox(height: 24),

                  _buildLocationCard(context),
                  const SizedBox(height: 24),

                  // --- NEW: Identification Sheet Button ---
                  _buildIdentificationCard(context),
                  // ----------------------------------------

                  // Espace supplémentaire en bas pour ne pas être caché par la BottomNavBar
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }






  Widget _buildIdentificationCard(BuildContext context) {
    // 1. Récupérer l'état du profil via le Provider
    final authService = Provider.of<AuthService>(context);

    // LOGIQUE : Comment savoir si c'est rempli ?
    // Idéalement, ton User doit avoir un champ booléen ou on vérifie si un champ clé est vide.
    // Exemple : Si le téléphone ou la date de naissance est null, c'est pas rempli.
    // Tu devras adapter cette condition selon ton modèle User.
    bool isProfileComplete = authService.estIdentifie;
    // Ou authService.user?.estIdentifie == true;

    final theme = Theme.of(context);

    // Configuration du style selon l'état
    final badgeColor = isProfileComplete ? AppTheme.successColor : AppTheme.errorColor; // Vert ou Rouge
    final badgeText = isProfileComplete ? "Complet" : "À remplir";
    final badgeIcon = isProfileComplete ? Icons.check_circle : Icons.info;

    return Stack(
      children: [
        // --- LA CARTE PRINCIPALE (Légèrement modifiée pour laisser de la place au badge) ---
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const IdentificationScreen()),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
              // Bordure dorée si complet, rouge si incomplet (Optionnel, pour insister)
              border: Border.all(
                color: isProfileComplete
                    ? const Color(0xFFC0A040).withOpacity(0.3)
                    : AppTheme.errorColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                // Icône à gauche
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0A040).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_pin_rounded, color: Color(0xFFC0A040), size: 28),
                ),
                const SizedBox(width: 16),

                // Textes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Fiche d'identification",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isProfileComplete
                            ? "Vos informations sont à jour."
                            : "Action requise : Complétez votre profil.", // Texte incitatif
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isProfileComplete
                              ? theme.colorScheme.onSurface.withOpacity(0.6)
                              : AppTheme.errorColor, // Texte rouge si urgent
                          fontWeight: isProfileComplete ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Petite flèche (on la garde, mais on peut la cacher si besoin)
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),

// --- L'ÉTIQUETTE STYLÉE (BADGE) ---
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              // On arrondit seulement le coin en bas à gauche pour faire un effet "coin plié"
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppTheme.radiusMedium), // Suit la carte
                bottomLeft: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(-2, 2),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, color: Colors.white, size: 12),
                const SizedBox(width: 6),
                Text(
                  badgeText.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }






Widget _buildAppBarContent(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // --- WRAPPER CLICABLE POUR L'AVATAR ET STATUT ---
      InkWell(
        onTap: () {
          // Navigue vers l'écran de modification du profil
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
          print('Avatar tapped, navigating to Edit Profile');
        },
        // Optionnel: Rendre l'effet d'ondulation circulaire si tu préfères
        // customBorder: const CircleBorder(),
        // Ou laisse rectangulaire pour inclure le texte "En ligne"
        borderRadius: BorderRadius.circular(8), // Léger arrondi pour l'effet
        child: Padding( // Ajoute un léger padding pour l'effet d'ondulation
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: (_userAvatarUrl != null && _userAvatarUrl!.isNotEmpty)
                    ? NetworkImage(_userAvatarUrl!)
                    : null,
                child: (_userAvatarUrl == null || _userAvatarUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 4),
              // --- DÉBUT MODIFICATION ---
              Text(
                l10n.online,
                style: TextStyle(
                  fontSize: 10,
                  // Petit bonus : GreenAccent ressort mieux en mode sombre que green[600]
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.greenAccent
                      : Colors.green[600],
                  fontWeight: FontWeight.bold,
                ),
              )
                  .animate(
                onPlay: (controller) => controller.repeat(reverse: true), // Boucle infinie aller-retour
              )
                  .fade(
                duration: 1000.ms, // Durée d'un cycle (1 seconde)
                begin: 0.4, // Commence à 40% d'opacité
                end: 1.0,   // Finit à 100% d'opacité
              ),
              // --- FIN MODIFICATION ---
            ],
          ),
        ),
      ),
      // --- FIN WRAPPER ---
      const SizedBox(width: 12),
      // Textes de bienvenue (inchangés)
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Text 'Bienvenue' et 'Que la paix...')
            Text(
              l10n.welcomeUser(_userName),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20, // Tu peux remettre si besoin
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.peaceMessage, // TODO: Localiser si nécessaire
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 4),


      // --- 3. NOUVELLE ICÔNE PARAMÈTRES (DROITE) ---
      IconButton(
        icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.onSurface, size: 28),
        tooltip: l10n.settings,
        onPressed: () {
          // Navigation vers SettingsScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
      // Cloche de notification (inchangée)
      // 1. On utilise un Consumer pour écouter les changements
      Consumer<AuthService>(
        builder: (context, authService, child) {

          // 2. On utilise un Stack pour superposer le point rouge
          return Stack(
            alignment: Alignment.center,
            children: [
              // Le bouton icône
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.onSurface, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                  print('Notifications tapped');
                },
              ),

              // 3. Le point rouge (conditionnel)
              if (authService.hasUnreadNotifications)
                Positioned(
                  top: 10, // Ajuste la position verticale
                  right: 10, // Ajuste la position horizontale
                  child: Container(
                    width: 10, // Taille du point
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5), // Petite bordure blanche
                    ),
                  ),
                ),
            ],
          );
        },
      )
    ],
  );
}



Widget _buildStatusSection(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l10n.homeStatusTitle,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 22,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var item in [
            {
              'count': _pendingCount,
              'title': l10n.homeStatusPending,
              'color': Colors.amber,
              'icon': FaIcon(FontAwesomeIcons.hourglassHalf, color: Colors.white, size: 20),
              'filter': (Map<String, dynamic> r) =>
              (r['statut'] ?? '').toLowerCase() == 'en_attente_paiement',
              'modalTitle': l10n.modal_pending,
            },
            {
              'count': _celebratedCount,
              'title': l10n.homeStatusCelebrated,
              'color': _greenColor,
              'icon': FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 20),
              'filter': (Map<String, dynamic> r) =>
              (r['statut'] ?? '').toLowerCase() == 'celebre',
              'modalTitle': l10n.modal_celebrated,
            },

            {
              'count': _upcomingCount,
              'title': l10n.homeStatusUpcoming,
              'color': _blueColor,
              'icon': FaIcon(FontAwesomeIcons.calendarDay, color: Colors.white, size: 20),

              // --- CORRECTION DU FILTRE ---
              'filter': (Map<String, dynamic> r) {
                String status = (r['statut'] ?? '').toString().toLowerCase();

                // 1. RÈGLE D'OR : On EXCLUT explicitement "en_attente_paiement"
                // Car ceux-là vont dans la carte Jaune (En attente).
                if (status == 'en_attente_paiement') return false;

                // 2. On EXCLUT Célébré et Annulé
                if (status.contains('celebre')) return false;
                if (status.contains('annul')) return false;

                // 3. On INCLUT seulement Confirmé ou En attente (de confirmation)
                // "en attente" (avec espace) = Payé mais pas encore validé par la paroisse
                // "confirmee" = Validé
                bool isConfirmed = status.contains('confirm');
                bool isWaitingValidation = status == 'en attente';

                // Vérification supplémentaire via les paiements (optionnel mais sécurisé)
                List<dynamic> p = r['paiements'] ?? [];
                bool isPaid = p.isNotEmpty && (p[0]['statut'] == 'paye' || p[0]['statut'] == 'confirmee');

                return isConfirmed || isWaitingValidation || isPaid;
              },
              // -----------------------------

              'modalTitle': l10n.modal_upcoming,
            },

          ])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  onTap: () => _showStatusModal(
                    item['modalTitle'] as String,
                    item['filter'] as bool Function(Map<String, dynamic>),
                  ),
                  child: _buildStatusCard(
                    item['count'] as int,
                    item['title'] as String,
                    item['color'] as Color,
                    item['icon'] as FaIcon,
                  ),
                ),
              ),
            ),
        ],
      )
    ],
  );
}





  void _showStatusModal(String title, bool Function(Map<String, dynamic>) filter) {
    // 1. Filtrage et Tri (Inchangé)
    final List<Map<String, dynamic>> filteredList = _allMassRequests
        .where((r) => filter(r as Map<String, dynamic>))
        .cast<Map<String, dynamic>>()
        .toList();

    filteredList.sort((a, b) =>
        _parseDateRobust(b['created_at'])
            .compareTo(_parseDateRobust(a['created_at'])));

    // 2. Affichage du Modal Flottant
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ✅ CRUCIAL : Fond invisible
      // transitionAnimationController: ... (Si tu veux contrôler la vitesse, optionnel)
      builder: (context) {

        // ✅ MAGIE : On enveloppe le tout dans un Padding pour le décoller
        return Padding(
          padding: EdgeInsets.only(
            left: 13,
            right: 13,
            // On ajoute la marge système (barre du bas iPhone) + 20px pour l'effet flottant
            bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
            top: 60, // Marge en haut pour ne pas coller tout en haut si la liste est longue
          ),
          child: Container(
            // ✅ DECORATION : On donne l'aspect "Carte" ici
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor, // ou cardTheme.color
              borderRadius: BorderRadius.circular(24), // Coins très arrondis (Google Style)
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            // Clip pour que le contenu (la liste) respecte les coins arrondis
            clipBehavior: Clip.antiAlias,

            // On appelle ton widget de contenu
            child: Column(
              mainAxisSize: MainAxisSize.min, // S'adapte à la hauteur du contenu
              children: [
                // Petit indicateur (Handle) visuel en haut pour dire "on peut glisser"
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Ton widget existant (il faudra peut-être enlever le Container décoratif à l'intérieur s'il en a déjà un)
                Flexible(
                  child: _StatusListModal(
                    title: title,
                    requests: filteredList,
                    findParishName: _findParishName,
                    formatDateTime: (date, time) {
                      try {
                        final dateTime = DateTime.parse('$date $time');
                        return DateFormat('dd/MM/yyyy / HH:mm', 'fr_FR').format(dateTime);
                      } catch (e) {
                        return date;
                      }
                    },
                    buildStatusBadge: (status) => _buildStatusBadge(status, null),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }





Widget _buildStatusCard(int count, String title, Color color, FaIcon icon) {
  return SizedBox(
    // Fixe la hauteur globale du card (tu peux ajuster)
    height: 100,
    child: Stack(
      clipBehavior: Clip.none, // Permet au badge de déborder
      fit: StackFit.expand, // <-- IMPORTANT : force le Stack à remplir l'Expanded parent
      children: [
        // 1. La carte principale (remplit désormais toute la largeur)
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // L'icône
              icon,

              // Le titre
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 2. Le Badge (Positionné en haut à droite)
        Positioned(
          top: -8,
          right: -8, // collé correctement même si la carte remplit toute la largeur
          child: Container(
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}




/// MODIFIÉ : _buildStatusBadge (utilise la logique 'switch' complète)
Widget _buildStatusBadge(String status, List<dynamic>? paiements) {
  final l10n = AppLocalizations.of(context)!;

  Color backgroundColor;
  Color textColor;
  String statusText = status;
  String statusLower = status.toLowerCase();

  // Utilise la couleur primaire du thème au lieu de _ocreColor fixe
  final Color primaryColor = Theme.of(context).primaryColor;

  // Logique 'switch' (plus robuste)
  switch (statusLower) {
    case 'en_attente_paiement': // Non payé (underscore)
      backgroundColor = _ocreColor.withOpacity(0.15);
      textColor = primaryColor;
      statusText = l10n.status_waiting_payment;
      break;

    case 'en attente': // Payé, en att. confirmation (AVEC ESPACE)
      backgroundColor = AppTheme.successColor.withOpacity(0.15);
      textColor = AppTheme.successColor;
      statusText = l10n.status_waiting_confirmation;
      break;

    case 'confirmee':
      backgroundColor = AppTheme.successColor.withOpacity(0.15);
      textColor = AppTheme.successColor;
      statusText = l10n.status_confirmed;
      break;

    case 'celebre': // Célébré
      backgroundColor = AppTheme.infoColor.withOpacity(0.15);
      textColor = AppTheme.infoColor;
      statusText = l10n.status_celebrated;
      break;

    case 'annulee':
      backgroundColor = AppTheme.errorColor.withOpacity(0.15);
      textColor = AppTheme.errorColor;
      statusText = l10n.status_cancelled;
      break;

    default:
    // Si le statut est inconnu, on vérifie s'il est payé
    // (C'est une sécurité de l'ancienne logique que je garde)
      bool isPaid = paiements?.isNotEmpty == true &&
          (paiements![0]['statut'] == 'paye' || paiements![0]['statut'] == 'confirmee');

      if (isPaid) {
        backgroundColor = AppTheme.successColor.withOpacity(0.15);
        textColor = AppTheme.successColor;
        statusText = l10n.status_waiting_confirmation;
      } else {
        backgroundColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
        statusText = status; // Affiche le statut inconnu
      }
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
    ),
    child: Text(
      statusText,
      style: TextStyle( color: textColor, fontWeight: FontWeight.bold, fontSize: 11),
    ),
  );
}



Widget _buildNextMassesSection(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  if (_upcomingMasses.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeUpcomingSectionTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ✅ CORRECTION : Utilise la couleur de carte du thème (Gris foncé en sombre)
            color: Theme.of(context).cardTheme.color,

            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Center(
            child: Text(
              l10n.homeNoUpcoming,
              // ✅ CORRECTION : Texte gris adapté au mode
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
        )
      ],
    );
  }
  // (Copie juste le return du début, le reste est géré plus bas)
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l10n.homeUpcomingSectionTitle,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 22,
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _upcomingMasses.take(3).map((mass) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildNextMassCard(mass),
          )).toList(),
        ),
      ),
    ],
  );
}





Widget _buildNextMassCard(Map<String, dynamic> mass) {
  // ... (Tes déclarations de variables date, time, etc. ne changent pas) ...
  final String date = mass['date_souhaitee'];
  final String time = mass['heure_souhaitee'];
  final String intention = mass['motif_intention'] ?? 'Intention inconnue';
  final int parishId = mass['paroisse_id'];
  final List<dynamic>? paiements = mass['paiements'] as List?;
  final String parishName = _findParishName(parishId);

  DateTime dateTime;
  try {
    dateTime = DateTime.parse(date + ' ' + time);
  } catch(e) {
    dateTime = DateTime.now();
  }

  String formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(dateTime);
  String formattedTime = DateFormat('HH:mm').format(dateTime);

  return Container(
    width: 220,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      // ✅ CORRECTION : Utilise la couleur dynamique du thème
      color: Theme.of(context).cardTheme.color,

      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      boxShadow: AppTheme.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedDate,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          formattedTime,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface,),
        ),
        const SizedBox(height: 8),
        Text(
          intention,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          parishName,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),),  maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: _buildStatusBadge(mass['statut'] ?? 'inconnu', paiements),
        ),
      ],
    ),
  );
}







Widget _buildLocationCard(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return InkWell( // Rendre la carte cliquable
    onTap: _openMap, // Appelle la fonction pour ouvrir la carte
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium), // Pour l'effet d'ondulation
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        // Nouveau design avec dégradé (optionnel)
        gradient: LinearGradient(
          colors: [
            AppTheme.infoColor.withOpacity(0.8),
            AppTheme.infoColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Ou garde une couleur unie si tu préfères:
        // color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.infoColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.my_location, color: Colors.white, size: 32), // Icône plus visible
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre Position Actuelle', // Titre fixe
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white70, // Texte blanc semi-transparent
                  ),
                ),
                const SizedBox(height: 2),
                // Affiche un indicateur de chargement ou la localisation
                _isFetchingLocation
                    ? const SizedBox(
                  height: 16, // Hauteur fixe pour éviter les sauts d'UI
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  _displayLocation, // Affiche la localisation récupérée ou message d'erreur
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold, // Plus gras
                    color: Colors.white, // Texte blanc
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.launch, color: Colors.white70, size: 20), // Icône pour indiquer l'ouverture
        ],
      ),
    ),
  );
}


}




// AJOUTE CE NOUVEAU WIDGET À LA FIN DU FICHIER home_screen.dart

class _StatusListModal extends StatelessWidget {
  final String title;
  final List<dynamic> requests;
  final String Function(int) findParishName;
  final String Function(String, String) formatDateTime;
  final Widget Function(String) buildStatusBadge;

  const _StatusListModal({
    required this.title,
    required this.requests,
    required this.findParishName,
    required this.formatDateTime,
    required this.buildStatusBadge,
  });


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        // ✅ CORRECTION 1 : Fond dynamique (Noir en sombre, Blanc en clair)
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: SafeArea(
        child: Column(
          children: [
            // Poignée du modal
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                // ✅ CORRECTION 2 : Couleur de la poignée adaptée (Gris clair ou fonce)
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Titre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  // ✅ CORRECTION 3 : Couleur du titre dynamique
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const Divider(height: 24),
            // Liste
            Expanded(
              child: requests.isEmpty
                  ? Center(
                child: Text(
                  "Aucune demande ne correspond à ce statut.",
                  style: TextStyle(
                    // ✅ CORRECTION 4 : Texte vide dynamique
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _buildModalRequestCard(context, request);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildModalRequestCard(BuildContext context, Map<String, dynamic> request) {
    final String intention = request['motif_intention'] ?? 'Intention non spécifiée';
    final String status = request['statut'] ?? 'inconnu';
    final String date = request['date_souhaitee'];
    final String time = request['heure_souhaitee'];
    final int parishId = request['paroisse_id'];
    final String parishName = findParishName(parishId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        // ✅ CORRECTION ICI : Utilise la couleur de carte du thème (Gris foncé en sombre, Blanc en clair)
        color: Theme.of(context).cardTheme.color,

        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),

        // Optionnel : Tu peux garder l'ombre ou la retirer en mode sombre pour un look plus plat
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intention,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    // ✅ C'était déjà bon ici
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Paroisse $parishName',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    // ✅ C'était déjà bon ici
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDateTime(date, time),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    // ✅ C'était déjà bon ici
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          buildStatusBadge(status), // Affiche le badge de statut
        ],
      ),
    );
  }



}