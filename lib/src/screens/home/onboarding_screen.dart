import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maparoisse/src/screens/auth/login_screen.dart'; // Ajuste le chemin vers ton LoginScreen
import 'package:flutter/services.dart'; // Pour contrôler le système


// Couleur Ocre (copiée de ton SplashScreen)
const Color ocreColor = Color(0xFFC0A040);

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Action de naviguer vers l'écran de connexion
  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ce widget est le contenu de ton ancien _buildFinalScreen

    // --- MODIFICATION : Enveloppe le Scaffold ---
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          // --- Barre de navigation (en bas) ---
          // On la met en noir pour qu'elle se fonde dans le dégradé
          systemNavigationBarColor: Colors.black,
          // On met les icônes système (le trait) en blanc
          systemNavigationBarIconBrightness: Brightness.light,

          // --- Barre de statut (en haut) ---
          // Transparente pour laisser voir l'image
          statusBarColor: Colors.transparent,
          // Icônes (heure, batterie) en blanc pour être lisibles sur l'image
          statusBarIconBrightness: Brightness.light,
        ),

    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/marie_background.jpg'), // REMPLACE par ton image de Marie
            fit: BoxFit.cover,
          ),
        ),
        child: Container( // Dégradé sombre pour la lisibilité
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              )
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2), // Pousse le contenu vers le centre/bas
                Text(
                  'E-MESSE',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5.0, color: Colors.black.withOpacity(0.5))]
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Communauté Foi et partage',
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      shadows: [Shadow(blurRadius: 3.0, color: Colors.black.withOpacity(0.5))]
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 3), // Plus d'espace avant le bouton
                ElevatedButton(
                  onPressed: () => _navigateToLogin(context), // Action du bouton
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: ocreColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Commencer',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 60), // Espace en bas
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}