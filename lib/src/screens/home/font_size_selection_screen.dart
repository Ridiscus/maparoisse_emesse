import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/font_size_provider.dart';
import '../../app_themes.dart';
import 'package:maparoisse/l10n/app_localizations.dart'; // Ajuste le chemin


class FontSizeSelectionScreen extends StatelessWidget {
  const FontSizeSelectionScreen({super.key});

  // Helper pour obtenir le nom traduit du niveau de taille
  String _getFontSizeName(FontSizeLevel level, AppLocalizations l10n) {
    switch (level) {
      case FontSizeLevel.small:
        return l10n.fontSizeSmall;
      case FontSizeLevel.medium:
        return l10n.fontSizeMedium;
      case FontSizeLevel.large:
        return l10n.fontSizeLarge;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupère le provider
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // Liste des options
    final List<FontSizeLevel> sizeOptions = FontSizeLevel.values;

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
          l10n.settingsFontSize, // Titre localisé
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: sizeOptions.map((level) {
          final String sizeName = _getFontSizeName(level, l10n); // Nom traduit

          return RadioListTile<FontSizeLevel>(
            title: Text(sizeName, style: Theme.of(context).textTheme.bodyLarge),
            value: level, // La valeur est l'enum FontSizeLevel
            groupValue: fontSizeProvider.fontSizeLevel, // L'état actuel du provider
            onChanged: (newLevel) {
              if (newLevel != null) {
                // Appelle la méthode du provider pour changer la taille
                fontSizeProvider.setFontSizeLevel(newLevel);
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