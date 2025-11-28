import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_themes.dart';
// Importe le Provider qui gère la locale si tu en utilises un
import 'package:maparoisse/providers/locale_provider.dart';
import 'package:provider/provider.dart';

// Clé pour SharedPreferences
const String _keyLanguageCode = 'app_language_code';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Locale? _selectedLocale;
  bool _isLoading = true;

  // Liste des langues supportées par ton application
  // Associe le nom affiché à l'objet Locale correspondant
  final Map<String, Locale> _supportedLanguages = {
    'Français': const Locale('fr'),
    'English': const Locale('en'),
    // Ajoute d'autres langues ici si nécessaire
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  // Charge la locale sauvegardée
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_keyLanguageCode);

    setState(() {
      if (languageCode != null && languageCode.isNotEmpty) {
        _selectedLocale = Locale(languageCode);
      } else {
        // Si aucune langue n'est sauvegardée, utilise la langue système ou une langue par défaut
        // Ici, on prend la première langue supportée comme défaut si rien n'est trouvé
        _selectedLocale = _supportedLanguages.values.first; // Ou utilise WidgetsBinding.instance.window.locale
      }
      _isLoading = false;
    });
  }

  // Sauvegarde la locale et met à jour l'application
  // Sauvegarde la locale et met à jour l'application VIA PROVIDER
  Future<void> _changeLocale(Locale newLocale) async {
    if (_selectedLocale == newLocale) return; // Ne rien faire si c'est la même langue

    // --- MISE À JOUR DE LA LOCALE VIA PROVIDER ---
    // Appelle la méthode setLocale de ton LocaleProvider
    // listen: false car on est dans une fonction, pas dans build
    Provider.of<LocaleProvider>(context, listen: false).setLocale(newLocale);
    // --- FIN MISE À JOUR VIA PROVIDER ---

    // Met à jour l'état local pour que le RadioListTile sélectionné change immédiatement
    setState(() {
      _selectedLocale = newLocale;
    });

    // Optionnel: Affiche un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Langue changée en ${_getLanguageName(newLocale)}')),
    );

    // Note : La sauvegarde dans SharedPreferences est maintenant gérée DANS le LocaleProvider
  }

  // Helper pour obtenir le nom de la langue à partir de la locale
  String _getLanguageName(Locale locale) {
    return _supportedLanguages.entries.firstWhere(
            (entry) => entry.value == locale,
        orElse: () => _supportedLanguages.entries.first // Fallback
    ).key;
  }

  @override
  Widget build(BuildContext context) {
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
          'Langue de l\'application',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: _supportedLanguages.entries.map((entry) {
          final String languageName = entry.key;
          final Locale locale = entry.value;

          return RadioListTile<Locale>(
            title: Text(languageName, style: Theme.of(context).textTheme.bodyLarge),
            value: locale, // La valeur est l'objet Locale
            groupValue: _selectedLocale, // La sélection actuelle
            onChanged: (newLocale) {
              if (newLocale != null) {
                _changeLocale(newLocale);
              }
            },
            activeColor: AppTheme.primaryColor, // Couleur du bouton radio sélectionné
            // Ajoute un indicateur visuel (optionnel)
            // secondary: _selectedLocale == locale ? Icon(Icons.check, color: AppTheme.primaryColor) : null,
            controlAffinity: ListTileControlAffinity.trailing, // Radio à droite
          );
        }).toList(),
      ),
    );
  }
}