// ═══════════════════════════════════════════════════
// FILE: lib/shared/theme/app_theme.dart
//
// PURPOSE: Defines ALL colors and fonts for LibraSpace.
// Change one color here → it changes EVERYWHERE in the app.
//
// Lines that start with // are COMMENTS.
// Flutter ignores comments — they are notes for humans.
// ═══════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CLASS AppColors — holds all color definitions.
// A class is a container that holds related things together.
//
// "static const" means:
//   static = belongs to the class, not to any object made from it
//   const  = this value NEVER changes while the app runs
//
// Color(0xFF3D5AFE):
//   0xFF = this is a hex color code
//   3D5AFE = the hex code for indigo blue
//   Your boss used 861014 (red). Yours is 3D5AFE (blue). Very different.
class AppColors {
  // Main brand color — deep indigo blue
  // Used for: buttons, active icons, focused borders
  static const Color primary = Color(0xFF3D5AFE);

  // Second color — warm teal green
  // Used for: welcome screen gradient, success messages
  static const Color secondary = Color(0xFF00BFA5);

  // Page background — very light grey, almost white
  static const Color background = Color(0xFFF5F7FA);

  // Card color — pure white boxes that float over the background
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Dark text — very dark navy, nearly black
  static const Color textDark = Color(0xFF1A1A2E);

  // Grey text — for less important info like distances, labels
  static const Color textGrey = Color(0xFF6B7280);

  // ── HEATMAP COLORS ── (for your unique feature)
  // Traffic-light system showing library busyness

  // GREEN = lots of space (library is less than 60% full)
  static const Color heatGreen = Color(0xFF22C55E);

  // YELLOW = filling up (library is 60% to 85% full)
  static const Color heatYellow = Color(0xFFF59E0B);

  // RED = almost full or completely full (over 85%)
  static const Color heatRed = Color(0xFFEF4444);
}

// FUNCTION buildAppTheme() — creates the complete visual style for the app.
// A function is a block of code that does a job when you call it.
// We call this ONCE in app.dart and it styles the ENTIRE app automatically.
ThemeData buildAppTheme() {
  return ThemeData(
    // Material 3 = Google's newest design language.
    // Gives us modern rounded shapes automatically.
    // Your boss used older Material 2. Visually different.
    useMaterial3: true,

    // colorScheme = our complete color system
    // fromSeed generates a full color palette from one starting color
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
    ),

    // textTheme = Poppins font for ALL text in the app.
    // Your boss used Comfortaa and Roboto. Different look.
    textTheme: GoogleFonts.poppinsTextTheme(),

    // cardTheme = how all white card boxes look
    cardTheme: CardThemeData(
      color: AppColors.cardWhite,
      elevation: 2, // 2 = small drop shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // quite rounded corners
      ),
    ),

    // appBarTheme = the top bar on each screen (where title shows)
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardWhite,
      elevation: 0, // 0 = no shadow (flat look)
      centerTitle: true, // title is centered
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600, // semi-bold
      ),
      iconTheme: const IconThemeData(color: AppColors.textDark),
    ),

    // elevatedButtonTheme = how ALL buttons look across the whole app
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, // blue button
        foregroundColor: Colors.white, // white text
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16), // tall buttons
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // inputDecorationTheme = how ALL text input fields look
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background, // light grey inside the field
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none, // no border normally
      ),
      focusedBorder: OutlineInputBorder(
        // blue border when user is typing
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textGrey),
    ),

    // background color of every screen
    scaffoldBackgroundColor: AppColors.background,
  );
}
