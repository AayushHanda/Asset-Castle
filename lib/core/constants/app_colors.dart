import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette - Navy / Bright Blue
  static const Color primary = Color(0xFF015BFF);
  static const Color primaryLight = Color(0xFF6C9EFF);
  static const Color primaryDark = Color(0xFF0136A8);

  // Secondary Palette - Vibrant Green
  static const Color secondary = Color(0xFF00C853);
  static const Color secondaryLight = Color(0xFF4EEB8E);
  static const Color secondaryDark = Color(0xFF008C3A);

  // Accent - Warm Coral
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9E9E);
  static const Color accentDark = Color(0xFFE84545);

  // Success / Warning / Error
  static const Color success = Color(0xFF2ED573);
  static const Color successLight = Color(0xFFE8F8EE);
  static const Color warning = Color(0xFFFFBE21);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFFF4757);
  static const Color errorLight = Color(0xFFFFE8EA);

  // Dark Mode Colors - Deep Navy
  static const Color darkBg = Color(0xFF040A18);
  static const Color darkSurface = Color(0xFF0A1530);
  static const Color darkCard = Color(0xFF0E1C40);
  static const Color darkBorder = Color(0xFF1D3265);

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF5F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8ECF4);

  // Text Colors
  static const Color textDark = Color(0xFF1E1E2D);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFE8E8F0);
  static const Color textOnDarkMuted = Color(0xFF9898B8);

  // Status Colors
  static const Color active = Color(0xFF2ED573);
  static const Color repair = Color(0xFFFFBE21);
  static const Color retired = Color(0xFF95A5A6);
  static const Color assigned = Color(0xFF6C63FF);
  static const Color unassigned = Color(0xFF00D9FF);

  // Gradient Sets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF015BFF), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2ED573), Color(0xFF7BED9F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF040A18), Color(0xFF0A1530)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0E1C40), Color(0xFF0A1530)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
