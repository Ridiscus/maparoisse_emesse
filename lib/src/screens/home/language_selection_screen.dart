


import 'package:flutter/material.dart';
import '../../app_themes.dart';
import 'package:maparoisse/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  // Liste des langues supportées
  // On utilise 'static' pour y accéder facilement
  static final Map<String, Locale> _supportedLanguages = {
    'Français': const Locale('fr'),
    'English': const Locale('en'),
  };

  @override
  Widget build(BuildContext context) {
    // 1. On écoute le Provider. C'est lui la SEULE source de vérité.
    // Dès que la langue change, ce widget se redessine automatiquement.
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Langue de l\'application',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Plus besoin de _isLoading, le Provider est déjà prêt
      body: ListView(
        children: _supportedLanguages.entries.map((entry) {
          final String languageName = entry.key;
          final Locale itemLocale = entry.value;

          // Astuce : On compare les codes de langue (ex: 'fr' == 'fr')
          // pour éviter les soucis d'égalité d'objets Locale
          final bool isSelected = currentLocale?.languageCode == itemLocale.languageCode;

          return RadioListTile<String>(
            title: Text(languageName, style: Theme.of(context).textTheme.bodyLarge),

            // On utilise le code langue comme valeur pour la comparaison (plus robuste)
            value: itemLocale.languageCode,

            // La valeur sélectionnée est celle du Provider
            groupValue: currentLocale?.languageCode,

            onChanged: (String? newLanguageCode) {
              if (newLanguageCode != null) {
                // 1. Mise à jour via le Provider
                // On recrée la Locale à partir du code (ex: 'en')
                final newLocale = Locale(newLanguageCode);
                localeProvider.setLocale(newLocale);

                // 2. Feedback utilisateur
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Langue changée en $languageName'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            activeColor: AppTheme.primaryColor,
            controlAffinity: ListTileControlAffinity.trailing,
          );
        }).toList(),
      ),
    );
  }
}