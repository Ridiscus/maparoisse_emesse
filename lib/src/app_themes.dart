import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- FONCTION UTILITAIRE POUR REDIMENSIONNER LES POLICES ---
ThemeData applyFontSize(ThemeData theme, double multiplier) {
  TextStyle? scale(TextStyle? style) => style?.copyWith(fontSize: (style.fontSize ?? 14.0) * multiplier);

  return theme.copyWith(
    textTheme: theme.textTheme.copyWith(
      displayLarge: scale(theme.textTheme.displayLarge),
      displayMedium: scale(theme.textTheme.displayMedium),
      displaySmall: scale(theme.textTheme.displaySmall),
      headlineLarge: scale(theme.textTheme.headlineLarge),
      headlineMedium: scale(theme.textTheme.headlineMedium),
      headlineSmall: scale(theme.textTheme.headlineSmall),
      titleLarge: scale(theme.textTheme.titleLarge),
      titleMedium: scale(theme.textTheme.titleMedium),
      titleSmall: scale(theme.textTheme.titleSmall),
      bodyLarge: scale(theme.textTheme.bodyLarge),
      bodyMedium: scale(theme.textTheme.bodyMedium),
      bodySmall: scale(theme.textTheme.bodySmall),
      labelLarge: scale(theme.textTheme.labelLarge),
      labelMedium: scale(theme.textTheme.labelMedium),
      labelSmall: scale(theme.textTheme.labelSmall),
    ),
  );
}

class AppTheme {
  // === COULEURS GLOBALES (Partagées) ===
  static const Color primaryColor = Color(0xFFC0A040); // Rouge corail / Doré
  static const Color primaryVariant = Color(0xFFD4481F);
  static const Color secondaryColor = Color(0xFF4ECDC4);

  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color infoColor = Color(0xFF2196F3);

  // === PALETTE CLAIRE (Light Mode) ===
  static const Color _lightBackground = Color(0xFFFAFAFA); // Blanc cassé
  static const Color _lightSurface = Color(0xFFFFFFFF); // Blanc pur
  static const Color _lightTextPrimary = Color(0xFF2D3748); // Gris foncé
  static const Color _lightTextSecondary = Color(0xFF718096); // Gris moyen
  static const Color _lightDivider = Color(0xFFE2E8F0);

  // === PALETTE SOMBRE (Dark Mode) ===
  static const Color _darkBackground = Color(0xFF121212); // Noir presque pur
  static const Color _darkSurface = Color(0xFF1E1E1E); // Gris très foncé (pour les cartes)
  static const Color _darkTextPrimary = Color(0xFFFFFFFF); // Blanc
  static const Color _darkTextSecondary = Color(0xFFB0B0B0); // Gris clair
  static const Color _darkDivider = Color(0xFF2C2C2C); // Gris foncé

  // === CONSTANTES DE DESIGN ===
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusSmall = 8.0;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 1)),
  ];


  // 1. Couleurs statiques manquantes
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color accentColor = Color(0xFFDAA520); // Or/Ocre
  static const Color dividerColor = Color(0xFFE2E8F0);

  // 2. Dimensions manquantes
  static const double radiusXLarge = 24.0;

  // 3. Méthode utilitaire manquante
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmé':
      case 'célébrée':
      case 'completed':
        return infoColor;
      case 'en_attente':
      case 'pending':
        return warningColor;
      case 'annulée':
      case 'cancelled':
        return errorColor;
      default:
        return textSecondary;
    }
  }



  static ThemeData get lightHighContrastTheme {
    // On part du thème clair de base et on augmente le contraste
    return lightTheme.copyWith(
      colorScheme: lightTheme.colorScheme.copyWith(
        primary: const Color(0xFF000000), // Noir pur pour le contraste max
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: lightTheme.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
  }

  static ThemeData get darkHighContrastTheme {
    // On part du thème sombre de base
    return darkTheme.copyWith(
      colorScheme: darkTheme.colorScheme.copyWith(
        primary: const Color(0xFFFFFFFF), // Blanc pur pour le contraste max
        onPrimary: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: darkTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }



  // --- AJOUTS POUR CORRIGER LES ERREURS ---

  // --- AJOUTE CETTE LIGNE ---
  static const Color textSecondary = Color(0xFF718096);
  // --------------------------

  // 1. Réintroduction de textTertiary (statique pour l'instant)
  static const Color textTertiary = Color(0xFFA0AEC0);

  // 2. Réintroduction de cardColor (pour les références directes)
  static const Color cardColor = Color(0xFFFFFFFF);

  // 3. Gradients (Dégradés)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 4. Ombres
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x40D4AF37), // Couleur dorée/ocre
      blurRadius: 20,
      spreadRadius: -5,
      offset: Offset(0, 8),
    ),
  ];



  // ===========================================================================
  // 1. THÈME CLAIR (LIGHT)
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: _lightBackground, // FOND BLANC

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: _lightSurface,
        background: _lightBackground,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: _lightTextPrimary,
      ),

      // AppBar Clair
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _lightTextPrimary),
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.bold, color: _lightTextPrimary
        ),
      ),

// Cartes Claire
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
        shadowColor: Colors.black.withOpacity(0.05),
      ),

      // Inputs Clair
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _lightDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _lightDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: _lightTextSecondary),
        hintStyle: const TextStyle(color: _lightTextSecondary),
      ),

      // Textes Clair
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: _lightTextPrimary,
        displayColor: _lightTextPrimary,
      ),

      dividerTheme: const DividerThemeData(color: _lightDivider, thickness: 1),
    );
  }

  // ===========================================================================
  // 2. THÈME SOMBRE (DARK) - C'est ici que la magie opère
  // ===========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Indique à Flutter d'inverser les contrastes
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: _darkBackground, // FOND NOIR

      colorScheme: const ColorScheme.dark(
        primary: primaryColor, // On garde le doré/corail
        secondary: secondaryColor,
        surface: _darkSurface, // Cartes gris foncé
        background: _darkBackground,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: _darkTextPrimary, // Texte Blanc
      ),

      // AppBar Sombre
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackground, // Fond noir
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: _darkTextPrimary), // Icônes Blanches
        titleTextStyle: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.bold, color: _darkTextPrimary // Titre Blanc
        ),
      ),

      // Cartes Sombre
      cardTheme: CardThemeData(
        color: _darkSurface, // Gris foncé
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
      ),

      // Inputs Sombre
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C), // Fond des champs gris foncé
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: _darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkTextSecondary),
        hintStyle: const TextStyle(color: _darkTextSecondary),
      ),

      // Textes Sombre (Force le blanc)
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: _darkTextPrimary, // Blanc
        displayColor: _darkTextPrimary, // Blanc
      ),

      dividerTheme: const DividerThemeData(color: _darkDivider, thickness: 1),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
        ),
      ),
    );
  }
}

// === EXTENSION (Gardée comme tu l'avais) ===
extension ColorUtils on Color {
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}



// === AJOUTER CETTE CLASSE À LA FIN DU FICHIER ===
class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.12,
  );
  static TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 30, fontWeight: FontWeight.bold, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.16,
  );
  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.22,
  );
  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.29,
  );
  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.27,
  );
  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.50,
  );
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.normal, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.50,
  );
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.normal, color: AppTheme.textSecondary, height: 1.43,
  );
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.lightTheme.colorScheme.onSurface, height: 1.43,
  );
}