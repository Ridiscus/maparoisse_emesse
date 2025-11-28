import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Importation de Google Fonts
import '../../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../app_themes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/modern_card.dart'; // ✅ Importation du widget ModernCard
import 'login_screen.dart';
import 'package:maparoisse/src/widgets/loader_widget.dart';
import 'package:flutter/services.dart'; // Pour contrôler le système


// Définition de notre palette de couleurs pour plus de clarté
const Color _primaryColor = Color(0xFFC0A040); // Ocre Lumineux
const Color _secondaryColor = Color(0xFFC0A040); // Bleu Ciel
const Color _textColor = Color(0xFF5D4037); // Brun Foncé
const Color _backgroundColor = Color(0xFFFAFAFA); // Blanc Cassé

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  int _currentStep = 0;
  bool _isLoading = false;


  String? _civilite;

  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _userFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  File? _imageFile;
  final _picker = ImagePicker();

  late AnimationController _stepAnimationController;
  late Animation<double> _stepAnimation;


  // --- AJOUT : États pour la visibilité des mots de passe ---
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _stepAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stepAnimationController, curve: Curves.easeInOut),
    );
    _stepAnimationController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();

    _nameFocus.dispose();
    _userFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    _confirmPassFocus.dispose();

    _stepAnimationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.valNameEmpty;
    }
    if (value.trim().length < 2) {
      return l10n.valNameShort;
    }
    return null;
  }

  String? _validateUsername(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.valUsernameEmpty;
    }
    if (value.trim().length < 3) {
      return l10n.valUsernameShort;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return l10n.valUsernameInvalid;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.valEmailEmpty;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return l10n.valEmailInvalid;
    }
    return null;
  }


  String? _validatePhone(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.valPhoneEmpty;
    }
    // Vérifie si ça commence par '+'
    if (!value.trim().startsWith('+')) {
      return l10n.valPhonePrefix;
    }
    // Vérifie la longueur (ex: +225 07... donc min 10-12 caractères)
    if (value.trim().length < 8) {
      return l10n.valPhoneShort;
    }
    // Vérifie qu'il n'y a que des chiffres après le +
    // (On enlève le + et on vérifie si le reste est numérique)
    String digits = value.trim().substring(1);
    if (!RegExp(r'^[0-9\s]+$').hasMatch(digits)) {
      return l10n.valPhoneFormat;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.valPassEmpty;
    }
    if (value.length < 8) {
      return l10n.valPassShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.valConfirmPassEmpty;
    }
    if (value != _passCtrl.text) {
      return l10n.valPassMismatch;
    }
    return null;
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked != null) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      _showError(l10n.errImagePick);
    }
  }

  void _nextStep() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep < 2) {
      // Valide d'abord les champs de texte du formulaire
      if (!_formKeys[_currentStep].currentState!.validate()) {
        return;
      }

      // ✅ MODIFIÉ : Ajout d'une validation personnalisée pour la civilité à l'étape 0
      if (_currentStep == 0 && (_civilite == null || _civilite!.isEmpty)) {
        _showError(l10n.errCivilityRequired);
        return; // Bloque le passage à l'étape suivante si la civilité n'est pas choisie
      }

      // Si tout est valide, on avance
      setState(() => _currentStep++);
      _stepAnimationController.reset();
      _stepAnimationController.forward();
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _stepAnimationController.reset();
      _stepAnimationController.forward();
    }
  }


  Future<void> _submitRegistration() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKeys[2].currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      // On attend la réponse. Si ça échoue, ça part dans le 'catch'
      final success = await auth.register(
        fullName: _nameCtrl.text.trim(),
        username: _userCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text,
        civilite: _civilite!,
        photoPath: _imageFile?.path,
      );

      if (!mounted) return;

      if (success) {
        // --- SUCCÈS (Code inchangé) ---
        final double screenHeight = MediaQuery.of(context).size.height;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l10n.successRegisterRedirect))
                  ]
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.only(bottom: screenHeight - 135, left: 20, right: 20),
              duration: const Duration(seconds: 2),
            )
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // --- REDIRIGE VERS LOGIN ---
          Navigator.pushReplacement( // Utilise pushReplacement pour remplacer l'écran d'inscription
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          // Ou si tu as une route nommée '/login':
          // Navigator.pushReplacementNamed(context, '/login');
        }
      }

    } catch (e) {
      // --- GESTION ERREUR (Internet, Email pris, etc.) ---
      if (mounted) {
        // Nettoie le message d'erreur
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        _showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  void _showError(String message) {
    if (!mounted) return;

    // Récupère la hauteur
    final double screenHeight = MediaQuery.of(context).size.height;

    // Détecte si c'est une erreur réseau
    bool isNetworkError = message.contains('Internet') || message.contains('connexion') || message.contains('serveur');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
                isNetworkError ? Icons.wifi_off : Icons.error_outline,
                color: Colors.white
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: isNetworkError ? Colors.grey[800] : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
            bottom: screenHeight - 130,
            left: 20,
            right: 20
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ✅ On récupère le thème
    final isDark = theme.brightness == Brightness.dark;
    const Color primaryColor = Color(0xFFC0A040); // L'ocre peut rester fixe ou theme.primaryColor

    final l10n = AppLocalizations.of(context)!; // <--- INDISPENSABLE

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // ✅ CORRECTION 1 : Barre de nav système dynamique
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,

        statusBarColor: Colors.transparent,
        // ✅ CORRECTION 2 : Icônes de statut dynamiques
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        // ✅ CORRECTION 3 : Fond dynamique
        backgroundColor: theme.scaffoldBackgroundColor,

        appBar: _isLoading
            ? null
            : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            // ✅ Icône retour dynamique
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
          title: Text(
            'Inscription',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              // ✅ Titre dynamique
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
        ),
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
                Column(
                  children: [
                    // --- Stepper ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          bool isActive = index == _currentStep;
                          bool isCompleted = index < _currentStep;
                          Color circleColor = isActive || isCompleted ? primaryColor : Colors.transparent;
                          // ✅ Bordure grise adaptée au mode sombre
                          Color borderColor = isActive || isCompleted ? primaryColor : theme.dividerColor;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: circleColor,
                                border: Border.all(color: borderColor, width: 1.5),
                              ),
                            ),
                          );
                          }),
                      ),
                    ),

                    // --- Étapes du formulaire ---
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _stepAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _stepAnimation.value,
                            child: _buildCurrentStep(),
                          );
                        },
                      ),
                    ),

                    // --- Boutons de navigation ---
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  // ✅ Couleur texte et bordure dynamique
                                  foregroundColor: theme.colorScheme.onSurface,
                                  side: BorderSide(color: theme.colorScheme.onSurface),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _previousStep,
                                child: Text(l10n.registerBtnPrev),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _isLoading ? null : _nextStep,
                              child: _isLoading && _currentStep == 2
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(_currentStep == 2 ? 'Terminer' : l10n.registerBtnNext),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // --- 3. Loader Overlay ---
              if (_isLoading)
                Container(
                  // ✅ Fond du loader dynamique
                  color: theme.scaffoldBackgroundColor.withOpacity(0.85),
                  child: const CustomCircularLoader(color: primaryColor, size: 60),
                ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildSecurityStep();
      case 2:
        return _buildProfilePictureStep();
      default:
        return const SizedBox.shrink();
    }
  }


  Widget _buildPersonalInfoStep() {
    final theme = Theme.of(context);
    const Color primaryColor = Color(0xFFC0A040);

    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.registerStep1Title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, // ✅ Dynamique
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              l10n.registerStep1Subtitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6), // ✅ Dynamique
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 32),

            // --- Section Civilité ---
            Text(l10n.registerLabelCivility, style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ModernCard(
                    // ✅ Assure-toi que ModernCard utilise cardTheme.color par défaut
                    // backgroundColor: theme.cardTheme.color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onTap: () => setState(() => _civilite = 'M.'),
                    borderColor: _civilite == 'M.' ? primaryColor : null,
                    backgroundColor: _civilite == 'M.' ? primaryColor.withOpacity(0.1) : theme.cardTheme.color, // ✅ Fond carte

                    child: Center(child: Text(l10n.registerGenderMale, style: TextStyle(fontWeight: FontWeight.w600,
                        // ✅ Couleur texte sélectionné ou normal
                        color: _civilite == 'M.' ? primaryColor : theme.colorScheme.onSurface))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ModernCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onTap: () => setState(() => _civilite = 'Mme'),
                    borderColor: _civilite == 'Mme' ? primaryColor : null,
                    backgroundColor: _civilite == 'Mme' ? primaryColor.withOpacity(0.1) : theme.cardTheme.color, // ✅ Fond carte
                    child: Center(child: Text(l10n.registerGenderFemale, style: TextStyle(fontWeight: FontWeight.w600,
                        // ✅ Couleur texte sélectionné ou normal
                        color: _civilite == 'Mme' ? primaryColor : theme.colorScheme.onSurface))),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 24),

            ModernCard(
              // Si ModernCard n'a pas de fond par défaut, ajoute :
              backgroundColor: theme.cardTheme.color,
              child: Column(
                children: [
                  // Tes CustomTextFields devraient déjà être corrigés via le thème global
                  CustomTextField(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    label: l10n.registerLabelFullName,
                    hint: l10n.registerHintFullName,
                    prefixIcon: Icons.person_outline,
                    validator: _validateName,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _userFocus.requestFocus(),

                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.3, duration: 600.ms, delay: 300.ms),
                  // ... (Les autres champs sont identiques) ...
                  const SizedBox(height: 20),
                  CustomTextField(controller: _userCtrl, focusNode: _userFocus, label: l10n.registerLabelUsername, hint: l10n.registerHintUsername, prefixIcon: Icons.alternate_email, validator: _validateUsername, textInputAction: TextInputAction.next, onSubmitted: (_) => _emailFocus.requestFocus()).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.3, duration: 600.ms, delay: 400.ms),
                  const SizedBox(height: 20),
                  CustomTextField(controller: _emailCtrl, focusNode: _emailFocus, label: l10n.registerLabelEmail, hint: l10n.registerHintEmail, prefixIcon: Icons.email_outlined, validator: _validateEmail, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, onSubmitted: (_) => _phoneFocus.requestFocus()).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: -0.3, duration: 600.ms, delay: 500.ms),
                  const SizedBox(height: 20),
                  CustomTextField(controller: _phoneCtrl, focusNode: _phoneFocus, label: l10n.registerLabelPhone, hint: l10n.registerHintPhone, prefixIcon: Icons.phone_outlined, validator: _validatePhone, keyboardType: TextInputType.phone, textInputAction: TextInputAction.done).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideX(begin: -0.3, duration: 600.ms, delay: 600.ms),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildSecurityStep() {
    final theme = Theme.of(context);
    const Color secondaryColor = Color(0xFF4ECDC4); // Turquoise
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.registerStep2Title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, // ✅
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              l10n.registerStep2Subtitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6), // ✅
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 32),
            ModernCard(
              backgroundColor: theme.cardTheme.color, // ✅
              child: Column(
                children: [
                  CustomTextField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    label: l10n.registerLabelPassword,
                    hint: l10n.registerHintPassword,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        // ✅ Couleur icône œil
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: _validatePassword,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _confirmPassFocus.requestFocus(),
                  ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.3, duration: 600.ms, delay: 300.ms),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _confirmPassCtrl,
                    focusNode: _confirmPassFocus,
                    label: l10n.registerLabelConfirmPass,
                    hint: l10n.registerHintConfirmPass,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: theme.colorScheme.onSurface.withOpacity(0.6), // ✅
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    validator: _validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.3, duration: 600.ms, delay: 400.ms),
                  const SizedBox(height: 24),

                  // Bloc Exigences
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: secondaryColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: secondaryColor, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.registerPassReqTitle,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordRequirement(l10n.registerPassReqLen),
                        _buildPasswordRequirement(l10n.registerPassReqMix),
                        _buildPasswordRequirement(l10n.registerPassReqCommon),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.3, duration: 600.ms, delay: 500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper corrigé
  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.successColor, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                // ✅ Texte gris dynamique
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildProfilePictureStep() {
    final theme = Theme.of(context);
    const Color primaryColor = Color(0xFFC0A040);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.registerStep3Title,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, // ✅
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Ajoutez une photo de profil (optionnel)',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6), // ✅
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 48),
            ModernCard(
              backgroundColor: theme.cardTheme.color, // ✅
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // ✅ Couleur du cercle derrière la photo (Fond du scaffold)
                          color: theme.scaffoldBackgroundColor,
                          border: Border.all(
                            color: _imageFile != null ? primaryColor : theme.dividerColor,
                            width: 3,
                          ),
                          boxShadow: [
                            if (_imageFile != null)
                              BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: _imageFile != null
                            ? ClipOval(
                          child: Image.file(
                            _imageFile!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.add_a_photo_outlined,
                          size: 48,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ).then().shimmer(
                      duration: 1000.ms,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: _primaryColor, width: 1.5),
                        ),
                      ),
                      onPressed: _pickImage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined, color: _primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            _imageFile != null ? l10n.registerImgChange : l10n.registerImgChoose,
                            style: GoogleFonts.inter(
                              color: _primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
                    if (_imageFile != null) ...[
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => setState(() => _imageFile = null),
                        icon:  Icon(Icons.delete_outline, color: AppTheme.errorColor),
                        label: Text(
                          l10n.registerImgDelete,
                          style: GoogleFonts.inter(color: AppTheme.errorColor),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}