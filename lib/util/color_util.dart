import 'package:flutter/material.dart';

class ColorUtil {
  static const Color blurBorder = Color(0xFF3A3A3A);
  static const Color darkGreen = Color(0xFF1F8A47);

  static const Color primary = Color(0xFF0284C7); // Light Blue 600
  static const Color primaryDark = Color(0xFF0369A1); // Light Blue 700
  static const Color accent = Color(0xFF38BDF8); // Light Blue 400
  static const Color background = Color(0xFFF0F9FF); // Sky 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFE0F2FE); // Sky 100
  static const Color border = Color(0xFFBAE6FD); // Sky 200
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color danger = Color(0xFFEF4444); // Red 500

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)], // Light Blue 700 to Sky 500
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)], // Light Blue 600 to 400
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
        return const Color(0xFFF2F2F2);
      case 6:
        return const Color(0xFFEDEDED);
      default:
        return const Color(0xFFF7F7F7);
    }
  }
}
