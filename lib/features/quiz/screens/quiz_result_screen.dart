import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../topics/models/topic_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/quiz_question_model.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizAttemptModel attempt;
  final TopicModel topic;
  final List<QuizQuestion> questions;
  final Map<int, String> userAnswers;

  const QuizResultScreen({
    super.key,
    required this.attempt,
    required this.topic,
    required this.questions,
    required this.userAnswers,
  });

  bool get _isPassed => attempt.accuracy >= 80;

  int get _wrongAnswers => attempt.totalQuestions - attempt.correctAnswers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildScoreCard(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 26),
                    _buildSectionHeader(),
                    const SizedBox(height: 14),
                    ...List.generate(
                      questions.length,
                          (index) => _buildAnswerRow(index),
                    ),
                    const SizedBox(height: 24),
                    _buildButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          _roundIconButton(
            icon: Icons.home_rounded,
            onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kết quả Quiz',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${topic.emoji} ${topic.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _isPassed ? AppColors.successSoft : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _isPassed ? 'ĐẠT' : 'CỐ LÊN',
              style: TextStyle(
                color: _isPassed ? AppColors.success : AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.borderSoft,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 21,
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final mainColor = _isPassed ? AppColors.success : AppColors.primary;
    final softColor = _isPassed ? AppColors.successSoft : AppColors.primarySoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.065),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: softColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                _isPassed ? '🎉' : '💪',
                style: const TextStyle(fontSize: 38),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isPassed ? 'Xuất sắc!' : 'Cố lên nhé!',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isPassed
                ? 'Bạn đã hoàn thành bài quiz rất tốt.'
                : 'Ôn lại các câu sai để cải thiện điểm số.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${attempt.score}',
            style: TextStyle(
              color: mainColor,
              fontSize: 64,
              height: 0.95,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'điểm',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: attempt.accuracy / 100),
              duration: const Duration(milliseconds: 900),
              builder: (_, value, __) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: AppColors.borderSoft,
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                );
              },
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Độ chính xác: ${attempt.accuracy.toStringAsFixed(1)}%',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statBox(
          icon: Icons.check_circle_rounded,
          value: '${attempt.correctAnswers}',
          label: 'Đúng',
          color: AppColors.success,
          bgColor: AppColors.successSoft,
        ),
        const SizedBox(width: 10),
        _statBox(
          icon: Icons.cancel_rounded,
          value: '$_wrongAnswers',
          label: 'Sai',
          color: AppColors.error,
          bgColor: AppColors.errorSoft,
        ),
        const SizedBox(width: 10),
        _statBox(
          icon: Icons.timer_rounded,
          value: '${attempt.durationSeconds}s',
          label: 'Thời gian',
          color: AppColors.primary,
          bgColor: AppColors.primarySoft,
        ),
      ],
    );
  }

  Widget _statBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderSoft,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Chi tiết câu trả lời',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.borderSoft,
              width: 1,
            ),
          ),
          child: Text(
            '${questions.length} câu',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerRow(int index) {
    final question = questions[index];
    final selected = userAnswers[index] ?? '';
    final isCorrect = selected == question.correctAnswer;

    final color = isCorrect ? AppColors.success : AppColors.error;
    final bgColor = isCorrect ? AppColors.successSoft : AppColors.errorSoft;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isCorrect
                  ? Icons.check_rounded
                  : Icons.close_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.questionText,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                if (isCorrect)
                  _answerLine(
                    label: 'Đáp án',
                    value: question.correctAnswer,
                    color: AppColors.success,
                  )
                else ...[
                  _answerLine(
                    label: 'Bạn chọn',
                    value: selected.isEmpty ? 'Không có' : selected,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 4),
                  _answerLine(
                    label: 'Đáp án đúng',
                    value: question.correctAnswer,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerLine({
    required String label,
    required String value,
    required Color color,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Về trang chủ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
                width: 1.4,
              ),
            ),
            child: const Center(
              child: Text(
                'Làm lại',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}