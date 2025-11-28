import 'package:flutter/material.dart';
import '../../app_themes.dart';
// Importe tes localisations si tu veux traduire le titre
// import 'package:maparoisse/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Politique de confidentialité', // l10n.settingsPrivacyPolicy
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
              'Politique de Confidentialité',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Date d\'entrée en vigueur : [Date]\n\nNous respectons votre vie privée...'),
            SizedBox(height: 10),
            Text(
              'Collecte d\'informations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Nous collectons les informations suivantes...'),
            SizedBox(height: 10),
            Text(
              'Utilisation des informations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Nous utilisons vos informations pour...'),
            // Ajoute toutes les sections nécessaires de ta politique
            // --- FIN CONTENU ---
          ],
        ),
      ),
    );
  }
}