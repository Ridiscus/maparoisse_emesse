import 'package:flutter/material.dart';
import '../../app_themes.dart';
// Importe tes localisations si tu veux traduire le titre
// import 'package:maparoisse/l10n/app_localizations.dart';

class FaqHelpScreen extends StatelessWidget {
  const FaqHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
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
          'FAQ / Aide', // l10n.settingsFaqHelp
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CONTENU À AJOUTER ICI ---
            Text(
              'Questions Fréquemment Posées',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Q: Comment faire une demande de messe ?\nR: Allez dans l\'onglet "Demande"...'),
            SizedBox(height: 20),
            Text(
              'Aide',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Pour toute assistance, veuillez contacter...'),
            // Ajoute plus de sections Q&R ou d'informations d'aide
            // --- FIN CONTENU ---
          ],
        ),
      ),
    );
  }
}