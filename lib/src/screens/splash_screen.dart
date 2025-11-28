import 'package:flutter/material.dart';
import 'dart:async'; // Pour Future.delayed
import 'package:google_fonts/google_fonts.dart'; // Si tu veux utiliser Google Fonts
import 'package:maparoisse/src/screens/auth/login_screen.dart'; // Importe ton écran de connexion
import 'package:provider/provider.dart';
import '../../src/services/auth_service.dart';
import '../../src/screens/home/dashboard_screen.dart';
import 'package:maparoisse/src/screens/home/onboarding_screen.dart';
import 'package:flutter/services.dart'; // Pour contrôler le système


// Définit les couleurs et durées
const Color ocreColor = Color(0xFFC0A040); // Couleur Ocre
const Color logoBlueColor = Color(0xFF5AC3C2); // Bleu/Turquoise du logo final
const Duration circleExpandDuration = Duration(milliseconds: 1500);
const Duration logoFadeDuration = Duration(milliseconds: 600);
const Duration textFadeDelay = Duration(milliseconds: 500);
const Duration backgroundFadeDuration = Duration(milliseconds: 800);
const Duration finalScreenDelay = Duration(milliseconds: 800);
const Duration totalAnimationDurationBeforeFinal = Duration(seconds: 3); // Ajuste la durée totale avant l'écran final

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Utilise TickerProviderStateMixin pour les AnimationControllers
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Contrôleurs pour les différentes animations
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;

  late AnimationController _logoFadeController;
  late Animation<double> _logoFadeAnimation; // Pour logo blanc et texte
  late Animation<double> _logoBlueFadeAnimation; // Pour logo bleu

  late AnimationController _backgroundFadeController;
  late Animation<double> _backgroundFadeAnimation; // Pour transition ocre -> blanc

  // États pour gérer l'affichage des différentes étapes
  bool _showOcreBackground = false;
  bool _showWhiteLogo = false;
  bool _showLogoText = false;
  bool _fadeToWhiteBackground = false;
  bool _showBlueLogo = false;

  // DANS LA CLASSE _SplashScreenState

  @override
  void initState() {
    super.initState();

    // --- Contrôleur 1: Expansion du Cercle ---
    _circleController = AnimationController(
      vsync: this,
      duration: circleExpandDuration,
    );
    // L'animation du cercle va de 0.0 (rien) à 1.0 (plein)
    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _circleController, curve: Curves.easeInOut),
    );

    // --- Contrôleur 2: Apparition Logo Blanc + Texte / Logo Bleu ---
    _logoFadeController = AnimationController(
      vsync: this,
      duration: logoFadeDuration,
    );
    // Les animations de fondu vont de 0.0 (invisible) à 1.0 (visible)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_logoFadeController);
    _logoBlueFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_logoFadeController);

    // --- Contrôleur 3: Transition Fond Ocre -> Blanc ---
    _backgroundFadeController = AnimationController(
      vsync: this,
      duration: backgroundFadeDuration,
    );
    // Le fondu sortant va de 1.0 (visible) à 0.0 (invisible)
    _backgroundFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_backgroundFadeController);

    // --- Démarrage de la Séquence ---
    _startAnimationSequence();
  }

  // DANS LA CLASSE _SplashScreenState



  // DANS LA CLASSE _SplashScreenState

  Future<void> _startAnimationSequence() async {
    // Stage 1: Expansion du cercle
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() => _showOcreBackground = true);
    _circleController.forward();
    await Future.delayed(circleExpandDuration + const Duration(milliseconds: 500));

    // Stage 2: Apparition logo blanc puis texte
    setState(() => _showWhiteLogo = true);
    _logoFadeController.forward();
    await Future.delayed(textFadeDelay);
    setState(() => _showLogoText = true);
    await Future.delayed((logoFadeDuration - textFadeDelay) + const Duration(milliseconds: 700));

    // Stage 3: Transition vers fond blanc + logo bleu
    setState(() {
      _fadeToWhiteBackground = true;
      _showBlueLogo = true;
    });
    _backgroundFadeController.forward();
    _logoFadeController.reset();
    _logoFadeController.forward();
    // Attend la fin de la transition (plus besoin de pause ici)
    await Future.delayed(backgroundFadeDuration);

    // --- MODIFICATION DE LA LOGIQUE DE NAVIGATION ---
    // Stage 4 est supprimé, on navigue IMMÉDIATEMENT après l'animation

    if (mounted) {
      // Vérifie l'état de connexion via AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      bool loggedIn = await authService.isLoggedIn();

      if (loggedIn) {
        // Si connecté, va vers le Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreenWithIndex()),
        );
      } else {
        // Si non connecté, va vers l'ÉCRAN D'ONBOARDING
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()), // <-- CHANGEMENT ICI
        );
      }
    }
    // --- FIN DE LA MODIFICATION ---
  }


  @override
  void dispose() {
    _circleController.dispose();
    _logoFadeController.dispose();
    _backgroundFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcule la taille max pour l'expansion du cercle (diagonale de l'écran)
    final screenSize = MediaQuery.of(context).size;
    final maxRadius = (screenSize.width > screenSize.height ? screenSize.width : screenSize.height) * 1.5; // Un peu plus grand pour être sûr

    // --- MODIFICATION : Enveloppe le Scaffold ---
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          // --- Barre de navigation (en bas) ---
          systemNavigationBarColor: const Color(0xFFFFFFFF) ,
          systemNavigationBarIconBrightness: Brightness.dark,

          // --- Barre de statut (en haut) ---
          // Met le fond de la barre de statut en blanc
          statusBarColor: Colors.white,
          // Met les icônes de la barre de statut (heure, batterie) en sombre
          statusBarIconBrightness: Brightness.dark,
        ),


    child:  Scaffold(
      backgroundColor: Colors.white, // Fond initial
      body: Stack(
        alignment: Alignment.center,
        children: [
          // --- Fond Ocre Animé (Cercle qui s'étend) ---
          // --- Fond Ocre Animé (Cercle qui s'étend) ---
          // Masque le cercle dès que la transition vers le blanc commence
          if (_showOcreBackground && !_fadeToWhiteBackground) // <= NOUVELLE CONDITION
            AnimatedBuilder(
              animation: _circleAnimation,
              builder: (context, child) {
                // S'assure que le cercle est bien à sa taille maximale avant de disparaître
                final radiusFraction = _circleController.status == AnimationStatus.completed ? 1.0 : _circleAnimation.value;
                return ClipOval(
                  clipper: CircleClipper(radiusFraction: radiusFraction),
                  child: Container(color: ocreColor),
                );
              },
            ),

          // --- Fondu Sortant du Fond Ocre (pour transition vers blanc) ---
          if (_fadeToWhiteBackground)
            FadeTransition(
              opacity: _backgroundFadeAnimation,
              child: Container(color: ocreColor), // Couche ocre qui disparaît
            ),

          // --- Contenu Animé (Logos, Texte) ---
          // Logo Blanc + Texte
          if (_showWhiteLogo && !_fadeToWhiteBackground) // Visible avant la transition vers blanc
            FadeTransition(
              opacity: _logoFadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Fichier-6.png', // REMPLACE par ton logo blanc
                    height: 200, // Ajuste la taille
                  ),
                  if (_showLogoText)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
    //child: Text(
    //                  'E-MESSE',
    //                  style: GoogleFonts.montserrat( // Ou ta police
    //                    fontSize: 28,
    //                    fontWeight: FontWeight.bold,
    //                    color: Colors.white,
    //                  ),
                      //                ),
                    ),
                ],
              ),
            ),

          // Logo Bleu (apparaît pendant la transition vers blanc)
          if (_showBlueLogo)
            FadeTransition(
              opacity: _logoBlueFadeAnimation, // Utilise la même logique de fondu
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Image.asset(
                    'assets/images/Fichier-8.png', // REMPLACE par ton logo bleu
                    height: 200, // Ajuste la taille
                  ),
                  Padding( // Le texte reste
                    padding: const EdgeInsets.only(top: 16.0),
                    // child: Text(
                    //'E-MESSE',
    // style: GoogleFonts.montserrat(
    //                  fontSize: 28,
    //                  fontWeight: FontWeight.bold,
    //                  color: logoBlueColor, // Texte en bleu
                    //                ),
                    //),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    );
  }

}


// --- Helper Clipper pour l'animation du cercle ---
class CircleClipper extends CustomClipper<Rect> {
  final double radiusFraction;

  CircleClipper({required this.radiusFraction});

  @override
  Rect getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width > size.height ? size.width : size.height) * 1.5;
    final radius = maxRadius * radiusFraction;
    return Rect.fromCircle(center: center, radius: radius);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true; // Reclip à chaque frame de l'animation
  }
}