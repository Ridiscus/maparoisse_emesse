import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maparoisse/providers/theme_provider.dart'; // Ajuste le chemin
import '../../app_themes.dart';
import 'package:maparoisse/l10n/app_localizations.dart'; // Pour traduire les options

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  // Helper pour obtenir le nom traduit du thème
  String _getThemeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return "Clair"; // TODO: Localiser "Clair" -> l10n.themeLight
      case ThemeMode.dark:
        return "Sombre"; // TODO: Localiser "Sombre" -> l10n.themeDark
      case ThemeMode.system:
      default:
        return "Système"; // TODO: Localiser "Système" -> l10n.themeSystem
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupère le provider pour lire l'état actuel et appeler la méthode de changement
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // Liste des options de thème
    final themeOptions = {
      l10n.themeLight: ThemeMode.light, // TODO: Utilise l10n.themeLight comme clé
      l10n.themeDark: ThemeMode.dark,   // TODO: Utilise l10n.themeDark comme clé
      l10n.themeSystem: ThemeMode.system, // TODO: Utilise l10n.themeSystem comme clé
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.settingsAppTheme, // Utilise la clé localisée pour le titre
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: themeOptions.entries.map((entry) {
          final String themeName = entry.key; // Nom traduit
          final ThemeMode mode = entry.value; // Valeur ThemeMode

          return RadioListTile<ThemeMode>(
            title: Text(themeName, style: Theme.of(context).textTheme.bodyLarge),
            value: mode, // La valeur est l'objet ThemeMode
            groupValue: themeProvider.themeMode, // L'état actuel du provider
            onChanged: (newMode) {
              if (newMode != null) {
                // Appelle la méthode du provider pour changer le thème
                themeProvider.setThemeMode(newMode);
              }
            },
            activeColor: AppTheme.primaryColor, // Couleur du bouton radio sélectionné
            controlAffinity: ListTileControlAffinity.trailing, // Radio à droite
          );
        }).toList(),
      ),
    );
  }
}