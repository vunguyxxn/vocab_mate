import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuizProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final int correct;
  final String topicEmoji;

  const QuizProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.correct,
    required this.topicEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / total;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Câu $current/$total',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary)),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 4),
                  Text('$correct đúng',
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 500),
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.indigo),
              ),
            ),
          ),
        ],
      ),
    );
  }
}