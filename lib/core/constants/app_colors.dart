import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette - Premium Gold
  static const Color primary = Color(0xFFD4AF37);
  static const Color primaryLight = Color(0xFFE5C86C);
  static const Color primaryDark = Color(0xFFA68822);

  // Secondary Palette - Navy Blue
  static const Color secondary = Color(0xFF1C2A43);
  static const Color secondaryLight = Color(0xFF324669);
  static const Color secondaryDark = Color(0xFF0F1A2D);

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

  // Dark Mode Colors - Premium Deep Navy
  static const Color darkBg = Color(0xFF0B101E);
  static const Color darkSurface = Color(0xFF121B2F);
  static const Color darkCard = Color(0xFF18243E);
  static const Color darkBorder = Color(0xFF293B61);

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Text Colors
  static const Color textDark = Color(0xFF121B2F);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFF121B2F);
  static const Color textOnDark = Color(0xFFF8F9FA);
  static const Color textOnDarkMuted = Color(0xFFA0ABC0);

  // Status Colors
  static const Color active = Color(0xFF2ED573);
  static const Color repair = Color(0xFFFFBE21);
  static const Color retired = Color(0xFF9CA3AF);
  static const Color assigned = Color(0xFFD4AF37);
  static const Color unassigned = Color(0xFF324669);

  // Gradient Sets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE5C86C), Color(0xFFD4AF37)],
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
    colors: [Color(0xFF0B101E), Color(0xFF121B2F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF18243E), Color(0xFF121B2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
