// colors.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Main colors
  static const Color bgColor = Color(0xFFF0F6FF);      // Light blue background
  static const Color primary = Color(0xFF232965);      // Primary blue
  static const Color primaryDark = Color(0xFF1565C0);  // Darker blue
  static const Color accent = Color(0xFF64B5F6);       // Accent blue
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color red = Color(0xFFFF5722);
  static const Color orange = Color(0xFFFF9800);
  static const Color blue = Color(0xFF2196F3);
  static const Color purple = Color(0xFF9C27B0);
  static const Color pink = Color(0xFFE91E63);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color success = Color(0xFF4CAF50);

  // Category colors
  static const Color drinkColor = Color(0xFFE3F2FD);
  static const Color fruitsColor = Color(0xFFFFF3E0);
  static const Color vegetableColor = Color(0xFFE8F5E8);
  static const Color sweetsColor = Color(0xFFFCE4EC);
}



class AppTextStyles {
  static TextStyle get heading1 => GoogleFonts.openSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static TextStyle get heading0 => GoogleFonts.openSans(
    fontSize: 25,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle get heading2 => GoogleFonts.openSans(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static TextStyle get heading3 => GoogleFonts.openSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static TextStyle get body1 => GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static TextStyle get body2 => GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );

  static TextStyle get caption => GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );

  static TextStyle get button => GoogleFonts.openSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get price => GoogleFonts.openSans(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static TextStyle get discount => GoogleFonts.openSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}




