import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Tu l'utilises déjà
import '../../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../app_themes.dart';
import 'register_screen.dart'; // Garde l'import pour la navigation
import 'package:maparoisse/src/widgets/loader_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart'; // Pour contrôler le système
import 'package:maparoisse/src/screens/password_reset/forgot_password_screen.dart';

import 'dart:io'; // Pour Platform
import 'package:sign_in_with_apple/sign_in_with_apple.dart';




// --- Couleurs du Mockup ---
const Color _mockupTurquoise = Color(0xFF5AC3C2); // Couleur du titre "Se connecter"
const Color _mockupOcre = Color(0xFFC0A040); // Couleur du bouton principal
const Color _mockupFieldBorder = Color(0xFFE0E0E0); // Couleur bordure champ
const Color _mockupBackgroundColor = Colors.white; // Fond général

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();


  // Utilise TextEditingController standard
  final _emailOrUserCtrl = TextEditingController(); // Changé de _userCtrl à _emailCtrl
  final _passCtrl = TextEditingController();
  final _emailOrUserFocus = FocusNode(); // Changé de _userFocus
  final _passFocus = FocusNode();




  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // AJOUTE CETTE LIGNE OBLIGATOIREMENT
    serverClientId: '946263966195-7a7tqneqphc6sf5nqkaufii1hpkndgd9.apps.googleusercontent.com',
  );

  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrUserCtrl.dispose();
    _passCtrl.dispose();
    _emailOrUserFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }



  // --- NOUVEAU Validateur pour Email OU Username ---
  String? _validateEmailOrUsername(String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return l10n.loginValEmailEmpty;
    }
    if (value.trim().length < 3) { // Validation minimale
      return l10n.loginValEmailShort;
    }
    // Pas de validation spécifique email ici, AuthService s'en chargera
    return null;
  }
  // --- FIN NOUVEAU Validateur ---

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return l10n.loginValPassEmpty;

    }
    if (value.length < 8) {
      return l10n.loginValPassShort;
    }
    return null;
  }


  // --- _handleLogin CORRIGÉ (Gestion erreur réseau) ---
  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final loginInput = _emailOrUserCtrl.text.trim();
    final password = _passCtrl.text;

    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      // On attend le résultat. Si ça échoue pour le réseau, ça va sauter direct au 'catch'
      final success = await auth.loginWithEmailOrUsername(
        loginInput: loginInput,
        password: password,
      );

      if (!mounted) return;

      if (success) {
        // --- SUCCÈS ---
        final double screenHeight = MediaQuery.of(context).size.height;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(l10n.loginSuccess),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.only(bottom: screenHeight - 235, left: 20, right: 20),
          ),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // --- ÉCHEC AUTHENTIFICATION (Le serveur a répondu "Non") ---
        // C'est ici qu'on dit "Vérifiez vos identifiants"
        _showError(l10n.loginErrorCredentials);
      }

    } catch (e) {
      // --- ERREUR RÉSEAU OU TECHNIQUE ---
      // On récupère le message précis lancé par AuthService (ex: "Pas de connexion Internet")
      String errorMessage = e.toString().replaceAll('Exception: ', ''); // Nettoie le texte "Exception:"

      if (mounted) {
        _showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  // --- _handleAppleSignIn (exemple, à adapter) ---
  Future<void> _handleAppleSignIn() async {
    // ... (Logique Apple Sign In à ajouter)
  }





  // DANS L'ÉCRAN DE CONNEXION (ex: login_screen.dart)

  Future<void> _handleGoogleSignIn() async {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading || _isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {

      // --- AJOUTE CETTE LIGNE ---
      // Force la déconnexion de Google pour afficher la sélection de compte
      await _googleSignIn.signOut();
      // --- FIN DE L'AJOUT ---

      // 1. Tente la connexion avec Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Connexion Google annulée par l\'utilisateur.');
        setState(() => _isGoogleLoading = false);
        return;
      }

      // --- AJOUT DES PRINTS DE DÉBOGAGE ---
      print("--- [Google Sign-In] Données reçues de Google ---");
      print("Display Name: ${googleUser.displayName}");
      print("Email: ${googleUser.email}");
      print("Google ID: ${googleUser.id}");
      print("Photo URL: ${googleUser.photoUrl}"); // <-- Affiche l'URL reçue
      print("--------------------------------------------------");
      // --- FIN DE L'AJOUT ---

      // 2. Récupère l'authentification Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _showError(l10n.loginErrorGoogleToken);
        await _googleSignIn.signOut();
        setState(() => _isGoogleLoading = false);
        return;
      }

      final authService = Provider.of<AuthService>(context, listen: false);

      // --- CORRECTION : Passe l'ID Google ---
      // 3. Appelle la fonction avec les 4 arguments
      bool success = await authService.loginWithGoogle(
          idToken,
          googleUser.email,
          googleUser.displayName,
          googleUser.id, // <-- L'ID Google
          googleUser.photoUrl // <-- L'URL de la photo
      );
      // --- FIN CORRECTION ---

      if (!mounted) return;

      if (success) {
        // 1. Récupère la hauteur
        final double screenHeight = MediaQuery.of(context).size.height;

        // 2. Affiche le SnackBar en haut
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                // Petite icône Google ou Check
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      l10n.loginSuccessGoogle(googleUser.displayName ?? ''),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            // Positionnement en haut
            margin: EdgeInsets.only(
                bottom: screenHeight - 235,
                left: 20,
                right: 20
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        _showError(l10n.loginErrorCredentials);
        await _googleSignIn.signOut();
      }

    } catch (error) {
      print('Erreur Google Sign In: $error');
      if (mounted) {
        _showError(l10n.loginErrorGoogleGeneric);
      }
      await _googleSignIn.signOut();
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }







  void _showError(String message) {
    // Détecte si c'est une erreur de connexion pour adapter le message
    bool isNetworkError = message.contains('Internet') || message.contains('connexion');
    // Récupère la hauteur
    final double screenHeight = MediaQuery.of(context).size.height;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
                isNetworkError ? Icons.wifi_off : Icons.error_outline, // Icône Wifi barré si pas de net
                color: Colors.white
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
              ),
            ),
          ],
        ),
        // On peut utiliser une couleur différente (ex: Gris foncé ou Orange) pour le réseau, Rouge pour erreur
        backgroundColor: isNetworkError ? Colors.grey[800] : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
            bottom: screenHeight - 130,
            left: 20,
            right: 20
        ), // En bas standard, ou calculé pour être en haut si tu préfères
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Raccourci thème
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // ✅ CORRECTION 1 : Barre de nav système dynamique
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,

        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),

      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // ✅ CORRECTION 2 : Fond dynamique
        backgroundColor: theme.scaffoldBackgroundColor,

        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // --- 1. Image de Fond ---
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset('assets/images/chainz.jpg', fit: BoxFit.contain),
                ),
              ),

              // --- 2. Contenu ---
              if (!_isLoading)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40.0),

                            // --- Titre ---
                            Text(
                              l10n.loginTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: _mockupTurquoise,
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, duration: 500.ms),

                            const SizedBox(height: 40),

                            // --- Formulaire ---
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // Champ Email/User
                                  TextFormField(
                                    controller: _emailOrUserCtrl,
                                    focusNode: _emailOrUserFocus,
                                    style: TextStyle(color: theme.colorScheme.onSurface),
                                    decoration: _buildInputDecoration(
                                      hintText: l10n.loginHintEmailOrUser,
                                      prefixIcon: Icons.person_2_outlined,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmailOrUsername,
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => _passFocus.requestFocus(),
                                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, duration: 500.ms),

                                  const SizedBox(height: 20),

                                  // Champ Mot de passe

                                  TextFormField(
                                    controller: _passCtrl,
                                    focusNode: _passFocus,
                                    style: TextStyle(color: theme.colorScheme.onSurface),
                                    obscureText: _obscurePassword,
                                    decoration: _buildInputDecoration(
                                      hintText: l10n.loginHintPassword,
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _handleLogin(),
                                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, duration: 500.ms),

                                  const SizedBox(height: 30),

                                  // Bouton Connexion
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.login, color: Colors.white),
                                    label: Text(l10n.loginBtnLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                    onPressed: _isLoading || _isGoogleLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _mockupOcre,
                                      minimumSize: const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, duration: 500.ms),

                                  const SizedBox(height: 16),

                                  // Liens bas de page
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: _isLoading || _isGoogleLoading ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                        child: Text(
                                          l10n.loginCreateAccount,
                                          style: GoogleFonts.inter(color: _mockupOcre, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _isLoading || _isGoogleLoading ? null : () {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                                        },
                                        child: Text(
                                          l10n.loginForgotPassword,
                                          style: GoogleFonts.inter(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),

                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 700.ms),

                                  const SizedBox(height: 30),

                                  // Séparateur
                                  _buildDividerWithText(l10n.loginOrContinue).animate().fadeIn(delay: 800.ms),

                                  const SizedBox(height: 20),

                                  // --- BOUTONS SOCIAUX ---

                                  // 1. Google (Existant)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildSocialButton(
                                        iconPath: 'assets/images/google-logo.png',
                                        onPressed: _isGoogleLoading || _isLoading ? null : () { _handleGoogleSignIn(); },
                                      ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.3),
                                    ],
                                  ),

                                  // ✅ 2. APPLE (Uniquement sur iOS)
                                  if (Platform.isIOS) ...[
                                    const SizedBox(height: 20),
                                    SignInWithAppleButton(
                                      text: "Se connecter avec Apple", // Optionnel, par défaut c'est en anglais
                                      onPressed: () async {
                                        setState(() => _isLoading = true); // Affiche le loader global
                                        try {
                                          final auth = Provider.of<AuthService>(context, listen: false);
                                          bool success = await auth.signInWithApple();

                                          if (success && mounted) {
                                            // Redirection vers l'accueil
                                            Navigator.pushReplacementNamed(context, '/dashboard');
                                          } else if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Échec de la connexion Apple"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          // Gérer erreur
                                        } finally {
                                          if (mounted) setState(() => _isLoading = false);
                                        }
                                      },
                                      height: 50,
                                      // Style Noir pour être conforme aux guidelines Apple
                                      style: SignInWithAppleButtonStyle.black,
                                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                                    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 32.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),

             // --- 3. Loader ---
              if (_isLoading)
                Container(
                  color: theme.scaffoldBackgroundColor.withOpacity(0.85),
                  child: const CustomCircularLoader(
                    color: _mockupOcre,
                    size: 60.0,
                    strokeWidth: 3.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }







  InputDecoration _buildInputDecoration({required String hintText, required IconData prefixIcon, Widget? suffixIcon}) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hintText,
      // ✅ Couleur du hint dynamique
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),

      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
        // ✅ Couleur icône dynamique
        child: Icon(prefixIcon, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      suffixIcon: suffixIcon,
      filled: true,

      // ✅ FOND DU CHAMP (Blanc en clair, Gris en sombre)
      fillColor: theme.cardTheme.color,

      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor), // ✅ Bordure dynamique
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor), // ✅ Bordure dynamique
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _mockupOcre, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor, width: 1.5),
      ),
    );
  }


  // --- Helper pour le Séparateur ---
  Widget _buildDividerWithText(String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)), // ✅
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            text,
            // ✅ Couleur texte dynamique
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: theme.dividerColor, thickness: 1)), // ✅
      ],
    );
  }

  // --- Helper pour les Boutons Sociaux ---
  Widget _buildSocialButton({required String iconPath, required VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // ✅ Bordure dynamique
        side: BorderSide(color: Theme.of(context).dividerColor),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
        // Fond transparent ou cardColor selon préférence
        backgroundColor: Theme.of(context).cardTheme.color,
      ),
      child: Image.asset(
        iconPath,
        height: 24,
        width: 24,
      ),
    );
  }

} // Fin de _LoginScreenState