import 'package:flutter/material.dart';

/// Dekho brand palette — deep ink, marigold amber, deep teal, warm paper.
class DekhoColors {
  static const ink = Color(0xFF221C2A);
  static const inkSoft = Color(0xFF4A4356);
  static const paper = Color(0xFFFAF6EC);
  static const sand = Color(0xFFE9E1CC);
  static const sandDark = Color(0xFFD8CCB0);
  static const teal = Color(0xFF0E5F5C);
  static const tealDeep = Color(0xFF0A4442);
  static const marigold = Color(0xFFE8A020);
  static const marigoldDeep = Color(0xFFC77F0E);
  static const clay = Color(0xFFB4552D);
}

/// A map color theme: visited/unvisited fills, accent, and hero gradient.
/// Dekho's own visual variants — not copied from any other product.
class DekhoMapTheme {
  final String name;
  final String nameHi;
  final Color visited;
  final Color unvisited;
  final Color accent;
  final Color heroFrom;
  final Color heroTo;
  const DekhoMapTheme({
    required this.name,
    required this.nameHi,
    required this.visited,
    required this.unvisited,
    required this.accent,
    required this.heroFrom,
    required this.heroTo,
  });
}

const List<DekhoMapTheme> dekhoMapThemes = [
  DekhoMapTheme(
    name: 'Teal Ink',
    nameHi: 'टील इंक',
    visited: DekhoColors.marigold,
    unvisited: DekhoColors.sand,
    accent: DekhoColors.teal,
    heroFrom: DekhoColors.teal,
    heroTo: DekhoColors.tealDeep,
  ),
  DekhoMapTheme(
    name: 'Desert',
    nameHi: 'रेगिस्तान',
    visited: DekhoColors.clay,
    unvisited: Color(0xFFF1E3CB),
    accent: DekhoColors.marigoldDeep,
    heroFrom: Color(0xFF9A4A24),
    heroTo: Color(0xFF5E2C14),
  ),
  DekhoMapTheme(
    name: 'Monsoon',
    nameHi: 'मानसून',
    visited: Color(0xFF1D6FA5),
    unvisited: Color(0xFFD9E8F2),
    accent: Color(0xFF0E5F5C),
    heroFrom: Color(0xFF155E8A),
    heroTo: Color(0xFF0A2F44),
  ),
  DekhoMapTheme(
    name: 'Forest',
    nameHi: 'जंगल',
    visited: Color(0xFF2F7D32),
    unvisited: Color(0xFFDDE8D5),
    accent: DekhoColors.clay,
    heroFrom: Color(0xFF2A6B2E),
    heroTo: Color(0xFF12300F),
  ),
];

ThemeData dekhoTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: DekhoColors.teal,
    primary: DekhoColors.teal,
    secondary: DekhoColors.marigold,
    surface: DekhoColors.paper,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: DekhoColors.paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: DekhoColors.paper,
      foregroundColor: DekhoColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: DekhoColors.paper,
      selectedItemColor: DekhoColors.teal,
      unselectedItemColor: DekhoColors.inkSoft,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DekhoColors.sandDark, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: DekhoColors.sandDark),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DekhoColors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}
