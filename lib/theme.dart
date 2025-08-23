import 'package:flutter/material.dart';

class BrandColors {
  // Primary brand = medical red
  static const primary = Color(0xFFD7263D);
  static const primaryDark = Color(0xFFAA1C2F);
  static const accent = Color(0xFFEE5A24); // warm red/orange
  static const ink = Color(0xFF2C3E50);
  static const subtle = Color(0xFF6C757D);
}

ThemeData buildBrandTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: BrandColors.primary,
    fontFamily: 'Inter',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: BrandColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: BrandColors.ink,
      displayColor: BrandColors.ink,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: BrandColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: Colors.black12.withOpacity(.15)),
      labelStyle: const TextStyle(color: BrandColors.ink),
      backgroundColor: const Color(0xFFF3F4F6),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE9ECEF)),
  );
}

const redHeroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [BrandColors.primary, BrandColors.primaryDark],
);

const redCardGradient = LinearGradient(
  colors: [BrandColors.primary, BrandColors.primaryDark],
);

BoxShadow softBrandShadow(bool hover) => BoxShadow(
  color: BrandColors.primary.withOpacity(hover ? .35 : .25),
  blurRadius: hover ? 30 : 20,
  offset: const Offset(0, 10),
);
