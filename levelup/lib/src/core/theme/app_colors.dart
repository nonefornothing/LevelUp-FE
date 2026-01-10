import 'package:flutter/material.dart';

/// Centralized color definitions for consistent theming
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF03A9F4); // Light blue accent
  static const Color primaryDark = Color(0xFF0288D1);
  static const Color primaryLight = Color(0xFFB3E5FC);

  // Background colors
  static const Color background = Colors.black;
  static const Color surface = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  // Accent colors
  static const Color accent = Color(0xFF03A9F4);
  static const Color success = Colors.green;
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blueAccent;

  // Quest colors
  static const Color questMain = Color(0xFF4CAF50);
  static const Color questSide = Color(0xFF9C27B0);
  static const Color questDaily = Color(0xFFFF9800);
  static const Color questWeekly = Color(0xFF2196F3);

  // Progress colors
  static const Color progressBackground = Color(0xFF1E1E1E);
  static const Color progressFill = primary;

  // Border colors
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF3A3A3A);

  // Disabled colors
  static const Color disabled = Color(0xFF404040);
  static const Color disabledText = Color(0xFF606060);
}

