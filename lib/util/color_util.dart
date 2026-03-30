import 'package:flutter/material.dart';

class ColorUtil {
  static const Color blurBorder = Color(0xFF163F7A);
  static const Color darkGreen = Color(0xFF1F8A47);

  static const Color primary = Color(0xFF163F7A);
  static const Color primaryDark = Color(0xFF0B2446);
  static const Color accent = Color(0xFFD9A441);
  static const Color background = Color(0xFFF3F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FBFF);
  static const Color border = Color(0xFFD7E3F2);
  static const Color textPrimary = Color(0xFF102033);
  static const Color textSecondary = Color(0xFF5F7188);
  static const Color danger = Color(0xFFD15B57);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F2D59), Color(0xFF1D5DB6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionGradient = LinearGradient(
    colors: [Color(0xFF1B4F97), Color(0xFF2B72D6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static Color inventoryColor(int type) {
    switch (type) {
      case 4:
        return const Color(0xFF1A56A3);
      case 6:
        return const Color(0xFF2C8C52);
      default:
        return const Color(0xFFC08A22);
    }
  }

  static Color inventoryTint(int type) {
    switch (type) {
      case 4:
        return const Color(0xFFE9F1FF);
      case 6:
        return const Color(0xFFEAF8EF);
      default:
        return const Color(0xFFFFF7E7);
    }
  }
}
