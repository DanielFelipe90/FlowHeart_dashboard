import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0D0D0D);
  static const Color surfaceVariant = Color(0xFF111111);
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderBright = Color(0xFF444444);
  static const Color white = Color(0xFFFFFFFF);
  static const Color whiteSubtle = Color(0xFF888888);
  static const Color whiteDisabled = Color(0xFF444444);
  static const Color statusOnline = Color(0xFF4ADE80);
  static const Color statusOffline = Color(0xFFEF4444);
  static const Color statusWarning = Color(0xFFFACC15);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: white,
        secondary: white,
        onSurface: white,
        outline: border,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: white,
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            color: white,
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
          titleLarge: TextStyle(
            color: white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          titleMedium: TextStyle(
            color: white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodyLarge: TextStyle(
            color: white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: whiteSubtle,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(
            color: white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: white, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: statusOffline),
        ),
        hintStyle: const TextStyle(color: whiteDisabled, fontSize: 14),
        labelStyle: const TextStyle(color: whiteSubtle, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: white,
          foregroundColor: background,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: const BorderSide(color: white),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: white),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: white,
        unselectedItemColor: whiteDisabled,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle:
            const TextStyle(color: white, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
