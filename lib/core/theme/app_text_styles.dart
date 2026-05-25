import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headerLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    height: 1.12,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle headerMedium = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w900,
    height: 1.18,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: AppColors.textSecondary,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.1,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textSecondary,
  );
}