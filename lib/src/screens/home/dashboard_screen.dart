import 'package:flutter/material.dart';
import '../../app_themes.dart';
import 'home_screen.dart';
import 'requests_screen.dart';
import 'requests_list_screen.dart';
import 'package:maparoisse/l10n/app_localizations.dart';
import 'events_screen.dart';
import 'parish_screen.dart';
import 'package:maparoisse/utils/navigation_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart'; // Pour contrôler le système
import 'package:maparoisse/src/screens/password_reset/reset_password_screen.dart';
import 'dart:async'; // Pour StreamSubscription
import 'package:app_links/app_links.dart'; // NOUVEL IMPORT






class DashboardScreenWithIndex extends StatefulWidget {
  final int initialIndex;
  const DashboardScreenWithIndex({Key? key, this.initialIndex = 0})
      : super(key: key);

  // Clé pour changer d'onglet (EXISTANTE)
  static final GlobalKey<_DashboardScreenWithIndexState> globalKey =
  GlobalKey<_DashboardScreenWithIndexState>();

  // NOUVELLE CLÉ pour contrôler le Scaffold (pour le drawer)
  //static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  State<DashboardScreenWithIndex> createState() =>
      _DashboardScreenWithIndexState();
}

class _DashboardScreenWithIndexState extends State<DashboardScreenWithIndex> {
  late int _currentIndex;


// (Dans ta classe State)
  StreamSubscription<Uri>? _linkSubscription;
  final _appLinks = AppLinks(); // L'objet du nouveau package



  @override
  void initState() {
    super.initState();

    _initDeepLinks();

    // Initialise _currentIndex avec la valeur initiale du notifier ou du widget
    _currentIndex = bottomNavIndex.value; // Ou garde widget.initialIndex si c'est prioritaire au démarrage

    // --- AJOUTER UN LISTENER ---
    // Écoute les changements externes sur bottomNavIndex
    bottomNavIndex.addListener(_onBottomNavIndexChanged);
    // --- FIN AJOUT ---
  }



  @override
  void dispose() {
    _linkSubscription?.cancel(); // N'oublie pas de l'arrêter
    super.dispose();
  }



  /// Initialise l'écoute des Deep Links
  Future<void> _initDeepLinks() async {

    // Écoute les liens entrants (quand l'app est déjà ouverte)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (mounted) {
        print("Lien reçu (app ouverte): $uri");
        _handleDeepLink(uri);
      }
    });

    // --- CORRECTION ICI ---
    // Gère le cas où l'app était fermée et s'ouvre via le lien
    final initialUri = await _appLinks.getInitialAppLink(); // Ce n'est pas getInitialLink
    // --- FIN CORRECTION ---

    if (initialUri != null && mounted) {
      print("Lien reçu (app fermée): $initialUri");
      _handleDeepLink(initialUri);
    }
  }

  /// Analyse le lien et navigue
  void _handleDeepLink(Uri uri) {
    // On vérifie si c'est bien notre lien "maparoisse://reset-password"
    if (uri.scheme == 'maparoisse' && uri.host == 'reset-password') {
      // On extrait les infos
      final email = uri.queryParameters['email'];
      final otp = uri.queryParameters['otp'];

      if (email != null && otp != null) {
        print("Navigation vers ResetPassword avec Email: $email et OTP: $otp");

        // On navigue vers l'écran de changement de mot de passe
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email, otp: otp),
        ));
      }
    }
  }





  void goToIndex(int index) {
    if (index < 0 || index == _currentIndex) return; // Évite les rebuilds inutiles
    // Met à jour l'état local ET le notifier global
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
      // Met aussi à jour la valeur globale pour que d'autres parties de l'app soient au courant
      bottomNavIndex.value = index;
    }
  }


  // Méthode appelée lorsque bottomNavIndex change de l'extérieur
  void _onBottomNavIndexChanged() {
    // Met à jour l'index local si la valeur globale a changé
    if (mounted && _currentIndex != bottomNavIndex.value) {
      setState(() {
        _currentIndex = bottomNavIndex.value;
      });
    }
  }




  //void _onItemTapped(int index) {
    // On vérifie si l'utilisateur a cliqué sur "Mes Demandes" (qui a l'index 2)
//if (index == 1) {
      // Si c'est le cas, on affiche d'abord notre modal
      //_showRequestsInfoDialog(context);
      // Puis on navigue vers l'écran
      //goToIndex(index);
      //} else {
      // Pour tous les autres onglets, on navigue normalement
      //goToIndex(index);
  //  }
    // }


  void _onItemTapped(int index) {
    // On navigue directement vers l'index sélectionné, sans aucune condition ni dialogue.
    goToIndex(index);
  }




  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // === MISE À JOUR DE LA LISTE screens (5 éléments maintenant) ===
    final screens = <Widget>[
      // 0: Accueil
      HomeScreen(onNewRequest: () => goToIndex(2)), // Modifié pour pointer vers 'Demande' (index 2)

      // 1: Evenement (Placeholder - À CRÉER)
      const EventsScreen(),

      // 2: Demande
      const RequestsScreen(),

      // 3: Mes demandes
      RequestsListScreen(onNewRequest: () => goToIndex(2)), // Modifié pour pointer vers 'Demande'

      // 4: Paroisse (Placeholder - À CRÉER)
      const ParishScreen(),

      // L'écran Profil n'est plus dans le bottomNav
    ];
    // ================= FIN DE LA MISE À JOUR =================


    // --- AJOUTE CETTE LIGNE ---
     // Détecte si le clavier est visible
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

        // Récupère la luminosité actuelle (Clair ou Sombre)
        final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // ✅ CORRECTION 1 : La couleur du fond suit le thème (Blanc ou Noir)
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,

        // ✅ CORRECTION 2 : Les icônes (Carré, Rond, Retour) s'inversent
        // Si on est en mode sombre, on veut des icônes claires (Light).
        // Si on est en mode clair, on veut des icônes sombres (Dark).
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),


      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        // --- 1. LE NOUVEAU BOUTON D'ACTION CENTRAL (CORRIGÉ) ---
        floatingActionButton: isKeyboardVisible || _currentIndex == 2
            ? null // 👈 Si le clavier est visible, ne RIEN afficher
            : FloatingActionButton( // 👈 Sinon, affiche le bouton
          onPressed: () => _onItemTapped(2), // Pointe vers "Demande"
          backgroundColor:  AppTheme.infoColor,
          child: const Icon(
            FontAwesomeIcons.handHoldingHeart,
            color: Colors.white,
          ),
          elevation: 2.0,
        ),

        // --- 2. ON DIT À FLUTTER DE LE CENTRER ---
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // --- 3. ON REMPLACE BOTTOMNAVBAR PAR BOTTOMAPPBAR ---
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: const CircularNotchedRectangle(), // Crée l'encoche pour le FAB
          notchMargin: 8.0, // Espace autour du FAB
          elevation: 10.0, // Ajoute une ombre légère

          child: Container(
            height: 68, // Hauteur de la barre
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Espace les 4 icônes
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBottomNavItem(
                      icon: FontAwesomeIcons.chartBar, // Icône Font Awesome pour "Accueil"
                      activeIcon: FontAwesomeIcons.solidChartBar, // Version remplie pour l'état actif
                      label: l10n.nav_home,
                      index: 0,
                    ),
                    _buildBottomNavItem(
                      icon: FontAwesomeIcons.calendarDay, // Icône Font Awesome pour "Evenement"
                      activeIcon: FontAwesomeIcons.solidCalendarDays,
                      label: l10n.nav_event,
                      index: 1,
                    ),
                  ],
                ),
                // Espace pour les 2 icônes de droite
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBottomNavItem(
                      icon: FontAwesomeIcons.listAlt, // Icône Font Awesome pour "Mes demandes"
                      activeIcon: FontAwesomeIcons.solidListAlt,
                      label: l10n.nav_requests,
                      index: 3,
                    ),
                    _buildBottomNavItem(
                      icon: FontAwesomeIcons.church, // Icône Font Awesome pour "Paroisse"
                      activeIcon: FontAwesomeIcons.church,
                      label: l10n.nav_parish,
                      index: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // Fin de ta fonction build()





  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = (_currentIndex == index);

    // Récupère les couleurs dynamiques
    final theme = Theme.of(context);

    // Couleur inactive : Gris en mode clair, Gris clair/Blanc en mode sombre
    final Color inactiveColor = theme.iconTheme.color!.withOpacity(0.6);

    // Couleur active : La couleur principale de ton app (Doré/Corail) ou Noir/Blanc selon ton goût
    // Je te conseille d'utiliser la primaryColor pour que ça ressorte bien en mode sombre
    final Color activeColor = AppTheme.infoColor; // Ou theme.primaryColor

    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: 68,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                // ✅ CORRECTION COULEUR ICÔNE
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  // ✅ CORRECTION COULEUR TEXTE
                  color: isSelected ? activeColor : inactiveColor,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

