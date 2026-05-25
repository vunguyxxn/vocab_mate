import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum AnswerState { normal, correct, wrong, disabled }

class AnswerOptionCard extends StatelessWidget {
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;
  final int index;

  const AnswerOptionCard({
    super.key,
    required this.text,
    required this.state,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ['A', 'B', 'C', 'D'];

    Color bgColor;
    Color borderColor;
    Color textColor;
    Color labelBg;
    Widget? trailingIcon;

    switch (state) {
      case AnswerState.correct:
        bgColor = const Color(0xFFD1FAE5);
        borderColor = AppColors.success;
        textColor = const Color(0xFF065F46);
        labelBg = AppColors.success;
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 22,
        );
        break;
      case AnswerState.wrong:
        bgColor = const Color(0xFFFEE2E2);
        borderColor = AppColors.error;
        textColor = const Color(0xFF991B1B);
        labelBg = AppColors.error;
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: AppColors.error,
          size: 22,
        );
        break;
      case AnswerState.disabled:
        bgColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade200;
        textColor = AppColors.textSecondary;
        labelBg = Colors.grey.shade300;
        break;
      case AnswerState.normal:
        bgColor = Colors.white;
        borderColor = Colors.grey.shade200;
        textColor = AppColors.textPrimary;
        labelBg = const Color(0xFFEEF2FF);
        break;
    }

    return GestureDetector(
      onTap: state == AnswerState.normal ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: state == AnswerState.normal
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: labelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  labels[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}