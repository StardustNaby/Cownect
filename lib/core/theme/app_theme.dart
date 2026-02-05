import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Paleta de colores monocromática con alto contraste.
/// 
/// Diseñada para uso en campo bajo sol directo (modo claro)
/// y en oficina/casa (modo oscuro).
class AppColors {
  // Grises para modo claro (fondo claro)
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnBackground = Color(0xFF2C2C2C);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFBDBDBD);
  static const Color lightSecondary = Color(0xFF757575);

  // Grises para modo oscuro (fondo oscuro)
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkOnSurface = Color(0xFFF5F5F5);
  static const Color darkOnBackground = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkDivider = Color(0xFF616161);
  static const Color darkSecondary = Color(0xFF9E9E9E);

  // Verde Esmeralda para acciones principales (ambos modos)
  static const Color emeraldGreen = Color(0xFF0A9137);
  static const Color emeraldGreenDark = Color(0xFF076A29);
  static const Color emeraldGreenLight = Color(0xFF0DB34A);
  static const Color onEmeraldGreen = Color(0xFFFFFFFF);
}

/// Configuración del tema de la aplicación con enfoque en accesibilidad.
/// 
/// Características:
/// - Botones grandes (mínimo 56dp de altura)
/// - Tipografía clara (mínimo 16px para cuerpo)
/// - Espaciado generoso
/// - Alto contraste
/// - Ripple effect visible
/// - Soporte para modo claro y oscuro
class AppTheme {
  /// Tema claro optimizado para uso en campo bajo sol directo.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.emeraldGreen,
        onPrimary: AppColors.onEmeraldGreen,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightSurface,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        error: Colors.red.shade700,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // Botones grandes con ripple effect visible
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56), // 56dp mínimo
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          // Ripple effect más visible
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(88, 56), // 56dp mínimo
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56), // 56dp mínimo
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: AppColors.lightBorder,
            width: 2,
          ),
        ),
      ),
      // Tipografía con jerarquía clara
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.lightOnSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.lightOnSurface,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          fontSize: 18, // 18px para etiquetas críticas (ISO 25010 - Accesibilidad)
          fontWeight: FontWeight.normal,
          color: AppColors.lightOnSurface,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.lightOnSurface,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.lightSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
          letterSpacing: 0.5,
        ),
      ),
      // Espaciado generoso
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minVerticalPadding: 16,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.emeraldGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: AppColors.lightSecondary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.emeraldGreen,
        unselectedItemColor: AppColors.lightSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Tema oscuro optimizado para uso en oficina/casa.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.emeraldGreen,
        onPrimary: AppColors.onEmeraldGreen,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkSurface,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        error: Colors.red.shade400,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // Botones grandes con ripple effect visible
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56), // 56dp mínimo
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          // Ripple effect más visible
          splashFactory: InkRipple.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(88, 56), // 56dp mínimo
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56), // 56dp mínimo
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: AppColors.darkBorder,
            width: 2,
          ),
        ),
      ),
      // Tipografía con jerarquía clara
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkOnSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkOnSurface,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          fontSize: 18, // 18px para etiquetas críticas (ISO 25010 - Accesibilidad)
          fontWeight: FontWeight.normal,
          color: AppColors.darkOnSurface,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.darkOnSurface,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
          letterSpacing: 0.5,
        ),
      ),
      // Espaciado generoso
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minVerticalPadding: 16,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.emeraldGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: AppColors.darkSecondary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.emeraldGreen,
        unselectedItemColor: AppColors.darkSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

/// Provider que expone el tema claro de la aplicación.
/// 
/// Optimizado para uso en campo bajo sol directo.
final lightThemeProvider = Provider<ThemeData>((ref) {
  return AppTheme.lightTheme;
});

/// Provider que expone el tema oscuro de la aplicación.
/// 
/// Optimizado para uso en oficina/casa.
final darkThemeProvider = Provider<ThemeData>((ref) {
  return AppTheme.darkTheme;
});

/// Provider que expone el modo de tema actual.
/// 
/// Por defecto usa ThemeMode.system para seguir la configuración del dispositivo.
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

