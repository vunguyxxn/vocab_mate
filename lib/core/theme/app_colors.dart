import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primarySoft = Color(0xFFEEF2FF);

  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceSoft = Color(0xFFF9FAFB);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderSoft = Color(0xFFF1F5F9);

  static const Color indigo = primary;
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  static const Color successSoft = Color(0xFFECFDF5);
  static const Color errorSoft = Color(0xFFFEF2F2);
  static const Color warningSoft = Color(0xFFFFFBEB);
  static const Color blueSoft = Color(0xFFEFF6FF);
  static const Color pinkSoft = Color(0xFFFDF2F8);
  static const Color purpleSoft = Color(0xFFF5F3FF);

  // Giữ lại để code cũ không lỗi compile.
  // Dùng 1 màu để UI không còn cảm giác gradient.
  static const primaryGradient = LinearGradient(
    colors: [primary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const pinkGradient = LinearGradient(
    colors: [surface, surface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const greenGradient = LinearGradient(
    colors: [success, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const redGradient = LinearGradient(
    colors: [error, error],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const amberGradient = LinearGradient(
    colors: [warning, warning],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxShadow get softShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 14,
    offset: const Offset(0, 4),
  );

  static BoxShadow get buttonShadow => BoxShadow(
    color: primary.withValues(alpha: 0.22),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );
}