import 'package:flutter/material.dart';

// Colores del brand — extraídos del frontend web (index.css, OKLCH → hex)
class AppColors {
  static const primary      = Color(0xFFA0522D); // sienna
  static const secondary    = Color(0xFF004B49); // dark teal
  static const accent       = Color(0xFFD2B48C); // warm tan
  static const background   = Color(0xFFF8F7F5); // warm off-white
  static const card         = Color(0xFFFFFFFF);
  static const muted        = Color(0xFF6B7280);
  static const destructive  = Color(0xFFEF4444);
  static const border       = Color(0xFFE8E4DF);
  static const foreground   = Color(0xFF342822); // dark brown-black
  static const sidebar      = Color(0xFF1B3F3D); // dark teal sidebar
  static const sidebarAccent = Color(0xFFD2B48C); // tan highlight
  static const sidebarDarkStart = Color(0xFF002926); // gradient de fondo (login/appbar)
  static const sidebarDarkEnd   = Color(0xFF003D3A); // gradient de fondo (login/appbar)
  static const success      = Color(0xFF10B981);
  static const warning      = Color(0xFFF59E0B);
  static const logoutRed    = Color(0xFFFC8181); // rojo suave para "Cerrar sesión" en el drawer oscuro
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 0.5,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.sidebar,
      width: 260,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontSize: 12, color: AppColors.foreground),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    fontFamily: 'Roboto',
  );
}
