// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  /// Thème clair principal de COBIT Metrics
  static ThemeData light() {
    // Base Material 3 avec une couleur "seed" pro (bleu-gris)
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF37474F), // bleu-gris pro
      brightness: Brightness.light,
    );

    final colorScheme = base.colorScheme;

    return base.copyWith(
      // Couleur de fond globale des écrans
      scaffoldBackgroundColor: const Color(0xFFF4F5F7),

      // AppBar uniforme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards (listes d’audits, organisations, domaines, etc.)
      cardTheme: const CardThemeData(
        elevation: 1,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ListTiles uniformes (padding, densité)
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: false,
      ),

      // Boutons principaux (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Boutons de type FilledButton (actions positives)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Boutons Outlined (actions secondaires)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),

      // FloatingActionButton (bouton + en bas à droite)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Champs de texte (TextField, dans les dialogs, formulaires…)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.75)),
      ),

      // Chips (statuts d’audit, criticité des écarts, etc.)
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        labelStyle: base.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),

      // Snackbars (messages en bas d’écran)
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Textes globaux
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Icônes
      iconTheme: base.iconTheme.copyWith(
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
