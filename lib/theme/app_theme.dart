import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

TextStyle textStyle(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = AppColors.ink,
  double? height,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

TextStyle titleStyle(double size, {Color color = AppColors.ink}) {
  return GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.15,
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brown,
        surface: AppColors.paper,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.cream,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textStyle(15, weight: FontWeight.w700),
        ),
      ),
    );
  }
}
