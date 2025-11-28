// Fichier : app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'app_themes.dart';
import 'services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'package:maparoisse/l10n/app_localizations.dart';
import '../providers/font_size_provider.dart';
import '../providers/contrast_provider.dart';
import 'package:maparoisse/src/services/navigation_service.dart';





final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


class ParoisseApp extends StatelessWidget {
  const ParoisseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Le MultiProvider est parfait, il ne change pas.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => ContrastProvider()),
      ],
      child: Builder(
          builder: (context) {
            // On récupère tous nos providers
            final themeProvider = Provider.of<ThemeProvider>(context);
            final localeProvider = Provider.of<LocaleProvider>(context);
            final fontSizeProvider = Provider.of<FontSizeProvider>(context);
            final contrastProvider = Provider.of<ContrastProvider>(context);

            // --- LOGIQUE FINALE ET SIMPLIFIÉE ---

            // 1. On choisit le thème de base (parmi nos 4 options)
            ThemeData baseTheme;
            if (contrastProvider.isHighContrast) {
              baseTheme = themeProvider.themeMode == ThemeMode.dark
                  ? AppTheme.darkHighContrastTheme
                  : AppTheme.lightHighContrastTheme;
            } else {
              baseTheme = themeProvider.themeMode == ThemeMode.dark
                  ? AppTheme.darkTheme
                  : AppTheme.lightTheme;
            }

            // 2. On applique la taille de la police au thème qu'on vient de choisir.
            // C'est notre thème final qui contient TOUS les réglages.
            final ThemeData finalTheme = applyFontSize(baseTheme, fontSizeProvider.multiplier);

            return MaterialApp(
              scaffoldMessengerKey: scaffoldMessengerKey,
              title: 'E-Messe',
              locale: localeProvider.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,


              // --- AJOUTE CETTE LIGNE ---
              navigatorKey: NavigationService.navigatorKey,
              // --- FIN AJOUT ---

              // --- CORRECTION FINALE ---
              // On n'utilise PLUS que cette seule ligne pour le thème.
              // Elle contient déjà l'info (clair/sombre), le contraste ET la taille de police.
              theme: finalTheme,

              initialRoute: '/',
              routes: appRoutes,
            );
          }
      ),
    );
  }
}

