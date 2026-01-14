import 'package:flutter/material.dart';
import 'package:maparoisse/src/screens/home/tutorials_screen.dart';
import 'package:provider/provider.dart'; // Si tu utilises Provider pour le thème
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/font_size_provider.dart';
import '../../app_themes.dart'; // Vérifie le chemin
import '../../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart'; // Pour les polices
import 'package:maparoisse/l10n/app_localizations.dart'; // Ajuste le chemin si nécessaire
import 'package:maparoisse/src/screens/home/edit_profile_screen.dart';
import 'package:maparoisse/src/screens/home/language_selection_screen.dart';
import 'package:maparoisse/providers/locale_provider.dart';
import 'package:maparoisse/src/screens/home/faq_help_screen.dart';
import 'package:maparoisse/src/screens/home/privacy_policy_screen.dart';
import 'package:maparoisse/providers/theme_provider.dart';
import 'package:maparoisse/src/screens/home/theme_selection_screen.dart';
import 'package:maparoisse/src/screens/home/font_size_selection_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maparoisse/src/screens/password_reset/forgot_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- États pour les Toggles ---

  // --- Clés pour SharedPreferences ---
  static const String _keySmsEnabled = 'notifications_sms_enabled';
  static const String _keyEmailEnabled = 'notifications_email_enabled';
  static const String _keyPushEnabled = 'notifications_push_enabled';

  // --- États pour les Toggles (avec valeurs par défaut) ---
  bool _smsEnabled = true; // Valeur par défaut si rien n'est sauvegardé
  bool _emailEnabled = true;
  bool _pushEnabled = true;
  bool _isLoadingSettings = true; // Pour afficher un indicateur pendant le chargement

  // Couleur thématique (turquoise/bleu-vert du bouton déconnecter)
  final Color _buttonColor = const Color(0xFF68A4A3); // Ajuste si besoin


  @override
  void initState() {
    super.initState();
    _loadNotificationSettings(); // Charge les préférences au démarrage
  }



  // --- Fonction pour CHARGER les préférences ---
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Charge la valeur sauvegardée ou utilise la valeur par défaut (true)
      _smsEnabled = prefs.getBool(_keySmsEnabled) ?? true;
      _emailEnabled = prefs.getBool(_keyEmailEnabled) ?? true;
      _pushEnabled = prefs.getBool(_keyPushEnabled) ?? true;
      _isLoadingSettings = false; // Fin du chargement
    });
  }

  // --- Fonction pour SAUVEGARDER une préférence ---
  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }


  @override
  Widget build(BuildContext context) {
    // Récupère l'instance de AppLocalizations
    final l10n = AppLocalizations.of(context)!;
    // Supposons que tu utilises Provider pour le thème
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Fond général
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack( // Utilisation du Stack pour l'image de fond
        fit: StackFit.expand,
        children: [
          // --- Image de fond transparente ---
          Positioned.fill(
            child: Opacity(
              opacity: 0.05, // Très faible opacité
              child: Image.asset(
                'assets/images/background_jesus.jpg', // REMPLACE par ton image de Jésus en croix
                fit: BoxFit.contain, // Couvre l'espace
              ),
            ),
          ),

          // --- Contenu des paramètres par-dessus ---
          // Affiche un loader si les settings ne sont pas encore chargés
          if (_isLoadingSettings)
            const Center(child: CircularProgressIndicator())
          else
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSettingsCard(
                      title: l10n.settingsAccountSectionTitle,
                      children: [
                        _buildSettingsItem(
                          icon: Icons.person_outline,
                          text: l10n.settingsEditProfile,
                          onTap: () {
                            // --- NAVIGATION VERS EditProfileScreen ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                            );
                            // --- FIN NAVIGATION ---
                          },
                        ),
                        const Divider(height: 1), // Séparateur
                        _buildSettingsItem(
                          icon: Icons.lock_outline,
                          text: l10n.settingsChangePassword,
                          onTap: () {
                            // --- NAVIGATION VERS ChangePasswordScreen ---
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                            // --- FIN NAVIGATION ---
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsCard(
                      title: l10n.settingsNotificationsSectionTitle,
                      children: [
                       /* _buildSwitchItem(
                          icon: Icons.sms_outlined,
                          text: l10n.settingsSmsNotifications,
                          value: _smsEnabled,
                          onChanged: (value) {
                            setState(() => _smsEnabled = value);
                            _saveNotificationSetting(_keySmsEnabled, value); // Sauvegarde
                          },
                        ), */
                        /*const Divider(height: 1),*/
                        /*_buildSwitchItem(
                          icon: Icons.email_outlined,
                          text: l10n.settingsEmailNotifications,

                          value: _emailEnabled,
                          onChanged: (value) { setState(() => _emailEnabled = value);
                          _saveNotificationSetting(_keyEmailEnabled, value); // Sauvegarde
                          },
                        ),*/
                        const Divider(height: 1),
                        _buildSwitchItem(
                          icon: Icons.notifications_active_outlined,
                          text: l10n.settingsPushNotifications,
                          value: _pushEnabled,
                          onChanged: (value) {
                            setState(() => _pushEnabled = value);
                            _saveNotificationSetting(_keyPushEnabled, value); // Sauvegarde
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSettingsCard(
                      title: l10n.settingsGeneralPrefsSectionTitle,
                      children: [
                        _buildSettingsItem(
                          icon: Icons.language,
                          text: l10n.settingsAppLanguage,
                          // Utilise la fonction helper mise à jour
                          trailing: Text(
                              _getCurrentLanguageNameLocalized(l10n), // Appel à la fonction qui utilise Provider
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),)
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
                            );
                            // Le setState ici forcera le rafraîchissement et rappellera _getCurrentLanguageName
                            setState(() {});
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsItem(
                          icon: Icons.format_size,
                          text: l10n.settingsFontSize,
                          // --- AJOUT TRAILING ---
                          trailing: Consumer<FontSizeProvider>( // Utilise Consumer pour réagir
                              builder: (context, fontSizeProvider, child) {
                                return Text(
                                    _getFontSizeNameLocalized(fontSizeProvider.fontSizeLevel, l10n), // Fonction helper
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),)
                                );
                              }
                          ),
                          // --- FIN AJOUT TRAILING ---
                          onTap: () {
                            // --- NAVIGATION vers FontSizeSelectionScreen ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FontSizeSelectionScreen()),
                            );
                            // Pas besoin de setState ici car Consumer gère le trailing
                            // --- FIN NAVIGATION ---
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsItem(
                          icon: Icons.record_voice_over_outlined,
                          text: l10n.settingsVoiceReader, // "Lecteur vocal"
                          onTap: () async {
                            // --- OUVRE LES PARAMÈTRES D'ACCESSIBILITÉ ---
                            // Note: Ceci n'est pas garanti de fonctionner sur tous les appareils/OS
                            // mais c'est la meilleure tentative.
                            // Pour Android:
                            const url = 'android.settings.ACCESSIBILITY_SETTINGS';
                            // Pour iOS (moins direct, ouvre les réglages généraux) :
                            // const url = 'App-Prefs:';

                            // On essaie d'ouvrir les paramètres Android directement
                            // Pour iOS, il n'y a pas d'URL directe garantie vers Accessibilité
                            final Uri uri = Uri(scheme: 'settings', path: url); // Essai pour Android

                            // Fallback: Ouvrir les réglages généraux si l'URL spécifique échoue ou pour iOS
                            final Uri generalSettingsUri = Uri(scheme: 'app-settings', path: ''); // iOS/Android

                            try {
                              // Tente d'abord l'URL spécifique (Android)
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else if (await canLaunchUrl(generalSettingsUri)) {
                                // Sinon, tente d'ouvrir les réglages généraux
                                await launchUrl(generalSettingsUri);
                              } else {
                                // Si rien ne fonctionne, affiche un message
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Impossible d'ouvrir les paramètres d'accessibilité."))
                                  );
                                }
                              }
                            } catch (e) {
                              print("Erreur ouverture paramètres accessibilité: $e");
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Erreur lors de l'ouverture des paramètres."))
                                );
                              }
                            }

                            // Affiche un message informatif en plus
                            if (mounted) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(l10n.settingsVoiceReader),
                                    content: const Text(
                                        "Activez TalkBack (Android) ou VoiceOver (iOS) dans les paramètres d'accessibilité de votre appareil pour utiliser la lecture d'écran avec l'application."
                                      // TODO: Localiser ce texte
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"), // TODO: Localiser ce texte
                                      )
                                    ],
                                  )
                              );
                            }
                            // --- FIN ---
                            print('Lecteur vocal tapped');
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsItem(
                          icon: Icons.palette_outlined,
                          text: l10n.settingsAppTheme,
                          // --- AJOUT TRAILING ---
                          trailing: Consumer<ThemeProvider>( // Utilise Consumer pour réagir aux changements
                              builder: (context, themeProvider, child) {
                                return Text(
                                    _getThemeModeName(themeProvider.themeMode, l10n), // Fonction helper
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),)
                                );
                              }
                          ),
                          // --- FIN AJOUT TRAILING ---
                          onTap: () {
                            // --- NAVIGATION vers ThemeSelectionScreen ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ThemeSelectionScreen()),
                            );
                            // Pas besoin de setState ici car Consumer gère le rafraîchissement du trailing
                            // --- FIN NAVIGATION ---
                          },
                        ),
                        const Divider(height: 1),
                        // ✅ NOUVEAU : TUTORIELS VIDÉO
                        _buildSettingsItem(
                          icon: Icons.ondemand_video, // Icône vidéo
                          text: l10n.settingsTutorials, // TODO: Localiser (l10n.settingsTutorials)
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TutorialsScreen()),
                            );
                          },
                        ),

                        const Divider(height: 1),
                        _buildSettingsItem(
                          icon: Icons.help_outline,
                          text: l10n.settingsFaqHelp,
                          onTap: () {
                            // --- NAVIGATION vers FAQ / Aide ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FaqHelpScreen()),
                            );
                            // --- FIN NAVIGATION ---
                          },
                        ),
                        const Divider(height: 1),
                        _buildSettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          text: l10n.settingsPrivacyPolicy,
                          onTap: () {
                            // --- NAVIGATION vers Politique ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                            );
                            // --- FIN NAVIGATION ---
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // --- BOUTON MODIFIÉ POUR LA SUPPRESSION ---
                    ElevatedButton(
                      onPressed: _showDeleteAccountDialog, // Nouvelle fonction
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor, // Couleur de danger (rouge)
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                      ),
                      child: Text(
                        "Supprimer mon compte", // TODO: Ajoute ceci à l10n (ex: settingsDeleteAccountButton)
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // --- FIN MODIFICATION ---
                    const SizedBox(height: 10), // Espace en bas
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }






  // --- AJOUT HELPER pour obtenir le nom traduit de FontSizeLevel ---
  String _getFontSizeNameLocalized(FontSizeLevel level, AppLocalizations l10n) {
    switch (level) {
      case FontSizeLevel.small:
        return l10n.fontSizeSmall;
      case FontSizeLevel.medium:
        return l10n.fontSizeMedium;
      case FontSizeLevel.large:
        return l10n.fontSizeLarge;
    }
  }



// --- AJOUT HELPER pour obtenir le nom du ThemeMode ---
  String _getThemeModeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight; // TODO: Utilise l10n.themeLight
      case ThemeMode.dark:
        return l10n.themeDark; // TODO: Utilise l10n.themeDark
      case ThemeMode.system:
      default:
        return l10n.themeSystem; // TODO: Utilise l10n.themeSystem
    }
  }

  // DANS LA CLASSE _SettingsScreenState

  // --- Modifie _getCurrentLanguageName pour utiliser les clés localisées ---
  String _getCurrentLanguageNameLocalized(AppLocalizations l10n) {
    final currentLocale = Provider.of<LocaleProvider>(context, listen: false).locale;

    if (currentLocale == null) {
      return l10n.loadingLabel; // Utilise clé pour "Chargement..."
    }

    // Retourne la clé localisée correspondante
    if (currentLocale.languageCode == 'fr') {
      return l10n.settingsCurrentLanguageFrench;
    } else if (currentLocale.languageCode == 'en') {
      return l10n.settingsCurrentLanguageEnglish;
    } else {
      // Fallback si une langue non explicitement nommée est ajoutée
      return currentLocale.languageCode.toUpperCase();
    }
  }






  // --- Widgets Réutilisables ---

  void _showLogoutDialog() async {
    final l10n = AppLocalizations.of(context)!;
    // ... (votre code existant, inchangé)
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        elevation: 20,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.drawerLogoutTitle,
              style: GoogleFonts.cormorantGaramond(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.drawerLogoutMessage,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            child: Text(
              l10n.drawerLogoutCancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.drawerLogoutConfirm,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final auth = Provider.of<AuthService>(context, listen: false);
      await auth.logout();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }


  // --- FONCTION FINALE DE SUPPRESSION (CORRIGÉE MODE SOMBRE) ---
  void _showDeleteAccountDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context); // Raccourci thème

    // 1. PREMIÈRE ÉTAPE : L'avertissement (Oui / Non)
    final shouldStartProcess = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        // ✅ CORRECTION 1 : Fond dynamique (Blanc ou Gris foncé)
        backgroundColor: theme.cardTheme.color,

        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Supprimer le compte",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  // ✅ CORRECTION 2 : Couleur du titre
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer votre compte ?\n\nCette action est irréversible et toutes vos données seront perdues immédiatement.",
          style: TextStyle(
            height: 1.4,
            // ✅ CORRECTION 3 : Couleur du texte du message
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
                l10n.drawerLogoutCancel,
                style: TextStyle(
                  // ✅ CORRECTION 4 : Couleur bouton Annuler
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                )
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Continuer"),
          ),
        ],
      ),
    );

    // Si l'utilisateur annule à la première étape, on arrête tout.
    if (shouldStartProcess != true || !mounted) return;

    // 2. DEUXIÈME ÉTAPE : Demander le mot de passe
    final password = await _promptForPassword();

    // Si l'utilisateur n'a pas entré de mot de passe ou a annulé
    if (password == null || password.isEmpty) return;

    // 3. TROISIÈME ÉTAPE : Appel API
    if (!mounted) return;

    // Loader sur fond transparent
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final auth = Provider.of<AuthService>(context, listen: false);

    // On récupère le Map (résultat + message)
    final result = await auth.deleteAccount(password);

    if (mounted) Navigator.of(context).pop(); // Ferme le loader

    if (result['success'] == true && mounted) {
      // SUCCÈS
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Votre compte a été supprimé."))
      );
    } else if (mounted) {
      // ÉCHEC
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ERREUR: ${result['message']}"),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 5),
          )
      );
    }
  }


  // --- NOUVELLE FONCTION : Demande le mot de passe (CORRIGÉE MODE SOMBRE) ---
  Future<String?> _promptForPassword() async {
    String? password;
    final theme = Theme.of(context); // Raccourci thème

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String input = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

          // ✅ CORRECTION 1 : Fond dynamique
          backgroundColor: theme.cardTheme.color,

          title: Text(
            "Vérification de sécurité",
            style: TextStyle(color: theme.colorScheme.onSurface), // Titre dynamique
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Veuillez entrer votre mot de passe pour confirmer la suppression définitive.",
                style: TextStyle(
                  // Message gris clair/moyen selon le thème
                    color: theme.colorScheme.onSurface.withOpacity(0.8)
                ),
              ),
              const SizedBox(height: 20),

              // ✅ CORRECTION 2 : TextField stylisé pour le sombre
              TextField(
                obscureText: true,
                autofocus: true,
                style: TextStyle(color: theme.colorScheme.onSurface), // Couleur de saisie
                onChanged: (value) => input = value,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),

                  // Fond du champ
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor ?? theme.scaffoldBackgroundColor,

                  // Bordures dynamiques (gris foncé en sombre, gris clair en blanc)
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                "Annuler",
                // Couleur bouton Annuler dynamique
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, input),
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }


  // Construit une carte pour une section
  Widget _buildSettingsCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color, // Fond blanc
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          // Les éléments de la section sont directement dans le Column
          ...children,
        ],
      ),
    );
  }

  // Construit un élément cliquable dans une carte
  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell( // Utilise InkWell pour l'effet de clic
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
            // Ajoute une flèche si pas de widget trailing spécifique
            if (trailing == null) Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  // Construit un élément avec un interrupteur
  Widget _buildSwitchItem({
    required IconData icon,
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    // Utilise SwitchListTile pour un rendu standard et accessible
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 22),
      title: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: _buttonColor, // Couleur du mockup
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }
}