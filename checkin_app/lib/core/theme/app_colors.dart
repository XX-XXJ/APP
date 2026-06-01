import 'package:flutter/material.dart';

class AppColors {
  // Dark mode flag
  static bool _isDark = false;
  static bool get isDark => _isDark;
  static void setDarkMode(bool value) => _isDark = value;

  // Primary - HyperOS Blue
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryLight = Color(0xFF7AB3EF);
  static const Color primaryDark = Color(0xFF2D6BB5);

  // Accent
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF9D96FF);

  // Background
  static Color get background => _isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FB);
  static Color get surface => _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  static Color get surfaceVariant => _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2F8);

  // Text
  static Color get textPrimary => _isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1A1D26);
  static Color get textSecondary => _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  static Color get textHint => _isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Check-in item colors
  static const List<Color> itemColors = [
    Color(0xFF4A90D9), // Blue
    Color(0xFF6C63FF), // Purple
    Color(0xFF34D399), // Green
    Color(0xFFFBBF24), // Yellow
    Color(0xFFF87171), // Red
    Color(0xFFFF8A65), // Orange
    Color(0xFF4DD0E1), // Cyan
    Color(0xFFE879F9), // Pink
    Color(0xFF81C784), // Light Green
    Color(0xFFFFB74D), // Light Orange
  ];

  // Achievement colors
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color diamond = Color(0xFFB9F2FF);

  // Gradient backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get homeGradient => _isDark
      ? const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFFF5F7FB), Color(0xFFE8ECF4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  static LinearGradient get cardGradient => _isDark
      ? const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF252525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
}
