import 'package:flutter/material.dart';

/// A utility class for text styles used throughout the app
class AppTextStyle {
  // Font family constants
  static const String primaryFontFamily = "Montserrat";
  static const List<String> fontFamilyFallbacks = ["sans-serif"];

  // Regular text styles
  static const TextStyle body = TextStyle(
    fontSize: 18,
    height: 1.6,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 16,
    height: 1.5,
  );
  
  // Heading styles
  static const TextStyle h1 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 1.2,
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallbacks,
  );
  
  static const TextStyle h2 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 1.3,
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallbacks,
  );
  
  static const TextStyle h3 = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 1.3,
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallbacks,
  );
  
  // Title styles
  static const TextStyle appBarTitle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    letterSpacing: 1.05,
    height: 1.75 / 1.125,
    fontFamily: primaryFontFamily,
    fontFamilyFallback: fontFamilyFallbacks,
  );
}