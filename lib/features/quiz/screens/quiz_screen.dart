import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../topics/models/topic_model.dart';
import '../../vocabulary/models/vocabulary_model.dart';
import '../models/quiz_question_model.dart';
import '../services/quiz_service.dart';
import '../widgets/answer_option_card.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final TopicModel topic;
  final List<VocabularyModel> vocabularies;
  final bool isPremium;

  const QuizScreen({
    super.key,
    required this.topic,
    required this.vocabularies,
    this.isPremium = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  final Map<int, String> _userAnswers = {};
  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    final maxQ = widget.isPremium ? null : 5;

    _questions = QuizService.generateQuestions(
      widget.vocabularies,
      maxQuestions: maxQ,
    );
  }

  QuizQuestion get _current => _questions[_currentIndex];

  int get _total => _questions.length;

  double get _progress => (_currentIndex + 1) / _total;

  int get _wrongCount => _userAnswers.length - _correctCount;

  String get _questionTypeText {
    return _current.type == QuestionType.wordToMeaning
        ? 'Chọn nghĩa đúng'
        : 'Chọn từ đúng';
  }

  IconData get _questionTypeIcon {
    return _current.type == QuestionType.wordToMeaning
        ? Icons.translate_rounded
        : Icons.text_fields_rounded;
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _userAnswers[_currentIndex] = answer;

      if (answer == _current.correctAnswer) {
        _correctCount++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (_currentIndex < _total - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        _submitQuiz();
      }
    });
  }

  Future<void> _submitQuiz() async {
    final duration = DateTime.now().difference(_startTime).inSeconds;

    try {
      final attempt = await QuizService.submitQuiz(
        topicId: widget.topic.id,
        questions: _questions,
        userAnswers: _userAnswers,
        durationSeconds: duration,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) {
            return QuizResultScreen(
              attempt: attempt,
              topic: widget.topic,
              questions: _questions,
              userAnswers: _userAnswers,
            );
          },
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu kết quả: $e')),
      );
    }
  }

  AnswerState _getState(String option) {
    if (!_answered) return AnswerState.normal;
    if (option == _current.correctAnswer) return AnswerState.correct;
    if (option == _selectedAnswer) return AnswerState.wrong;

    return AnswerState.disabled;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildEmptyHeader(),
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Cần ít nhất 4 từ để làm quiz!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            const SizedBox(height: 14),
            _buildStatsStrip(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionTypeChip(),
                    const SizedBox(height: 14),
                    _buildQuestionCard(),
                    const SizedBox(height: 24),
                    const Text(
                      'Chọn đáp án',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(
                      _current.options.length,
                          (index) {
                        final option = _current.options[index];

                        return AnswerOptionCard(
                          text: option,
                          state: _getState(option),
                          index: index,
                          onTap: () => _selectAnswer(option),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          _roundIconButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Quiz',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          _roundIconButton(
            icon: Icons.close_rounded,
            onTap: _showExitDialog,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quiz',
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
                  '${widget.topic.emoji} ${widget.topic.title}',
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
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_currentIndex + 1}/$_total',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
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

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _progress),
          duration: const Duration(milliseconds: 350),
          builder: (_, value, __) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: AppColors.borderSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(6),
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
        child: Row(
          children: [
            _miniStat(
              icon: Icons.check_circle_rounded,
              value: '$_correctCount',
              label: 'Đúng',
              color: AppColors.success,
              bgColor: AppColors.successSoft,
            ),
            const SizedBox(width: 6),
            _miniStat(
              icon: Icons.cancel_rounded,
              value: '$_wrongCount',
              label: 'Sai',
              color: AppColors.error,
              bgColor: AppColors.errorSoft,
            ),
            const SizedBox(width: 6),
            _miniStat(
              icon: Icons.quiz_rounded,
              value: '${_userAnswers.length}/$_total',
              label: 'Đã làm',
              color: AppColors.primary,
              bgColor: AppColors.primarySoft,
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 17,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _questionTypeIcon,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            _questionTypeText,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 210),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.help_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 34, 0, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Câu ${_currentIndex + 1}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _current.questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      height: 1.14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  if (_current.type == QuestionType.wordToMeaning &&
                      _current.vocabulary.phonetic != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _current.vocabulary.phonetic!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          title: const Text(
            'Thoát quiz?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Tiến độ quiz sẽ không được lưu nếu thoát.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Thoát',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}