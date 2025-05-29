import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.green,
      useMaterial3: false,      // Add more theme customizations here if needed
    );
  }

  // Custom colors for toggles
  static const Color toggleSelectedColor = Color(0xFF43A047); // Green[600]
  static const Color toggleUnselectedColor = Color(0xFFF1F8E9); // Green[50]
  static const Color toggleSelectedTextColor = Colors.white;
  static const Color toggleUnselectedTextColor = Colors.black87;
}