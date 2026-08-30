import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Agricultural Dark Theme (High Outdoor Contrast)
  static const Color primaryGreen = Color(0xFF2E7D32); // Deep Agricultural Green
  static const Color accentGreen = Color(0xFF4CAF50);  // Leaf Green / Primary Buttons
  static const Color lightGreen = Color(0xFF81C784);   // Soft Highlight Green
  static const Color darkBg = Color(0xFF121412);       // Dark Neutral Background
  static const Color surfaceDark = Color(0xFF1C201C);   // Card / Container Surface
  static const Color surfaceBorder = Color(0xFF2D352D); // Subtle Border Color
  
  static const Color textPrimary = Color(0xFFF5F7F5);  // High Contrast Text
  static const Color textSecondary = Color(0xFFA0ABA0);// Muted Secondary Text
  
  static const Color statusSuccess = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFB300);
  static const Color statusError = Color(0xFFE53935);
  static const Color statusInfo = Color(0xFF29B6F6);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'NotoSans',
      scaffoldBackgroundColor: darkBg,
      primaryColor: accentGreen,
      colorScheme: const ColorScheme.dark(
        primary: accentGreen,
        secondary: primaryGreen,
        surface: surfaceDark,
        error: statusError,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentGreen,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: accentGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accentGreen,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
