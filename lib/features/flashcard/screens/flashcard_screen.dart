import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/supabase_service.dart';
import '../../progress/models/user_word_progress_model.dart';
import '../../progress/services/progress_service.dart';
import '../../topics/models/topic_model.dart';
import '../../vocabulary/models/vocabulary_model.dart';

class FlashcardScreen extends StatefulWidget {
  final TopicModel topic;
  final List<VocabularyModel> vocabularies;

  const FlashcardScreen({
    super.key,
    required this.topic,
    required this.vocabularies,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  int _currentIndex = 0;
  bool _isFront = true;
  bool _isFlipping = false;

  Map<String, UserWordProgressModel> _progressMap = {};
  final Map<String, bool> _sessionAnswers = {};
  final String _userId = SupabaseService.currentUserId!;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initFlipAnimation();
    _loadProgress();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    final engines = await _tts.getEngines;
    debugPrint('TTS Engines: $engines');

    final languages = await _tts.getLanguages;
    debugPrint('TTS Languages: $languages');

    _tts.setErrorHandler((msg) => debugPrint('TTS Error: $msg'));
    _tts.setCompletionHandler(() => debugPrint('TTS Done'));
  }

  void _initFlipAnimation() {
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _loadProgress() async {
    final ids = widget.vocabularies.map((vocab) => vocab.id).toList();
    final map = await ProgressService.getProgressMap(_userId, ids);

    if (!mounted) return;

    setState(() => _progressMap = map);
  }

  VocabularyModel get _current => widget.vocabularies[_currentIndex];

  int get _total => widget.vocabularies.length;

  double get _pageProgress => (_currentIndex + 1) / _total;

  bool? get _currentStatus {
    if (_sessionAnswers.containsKey(_current.id)) {
      return _sessionAnswers[_current.id];
    }

    final progress = _progressMap[_current.id];
    if (progress == null) return null;

    return progress.isRemembered;
  }

  int get _rememberedCount {
    return _progressMap.values.where((progress) => progress.isRemembered).length;
  }

  int get _learnedCount {
    return _progressMap.length;
  }

  Future<void> _flipCard() async {
    if (_isFlipping) return;

    _isFlipping = true;

    if (_isFront) {
      await _flipController.forward();
    } else {
      await _flipController.reverse();
    }

    if (!mounted) return;

    setState(() => _isFront = !_isFront);
    _isFlipping = false;
  }

  Future<void> _speak() async {
    await _tts.stop();
    final result = await _tts.speak(_current.word);
    debugPrint('TTS result: $result');
  }

  Future<void> _markWord(bool isRemembered) async {
    setState(() => _sessionAnswers[_current.id] = isRemembered);

    await ProgressService.markWord(
      userId: _userId,
      vocabularyId: _current.id,
      isRemembered: isRemembered,
    );

    await _loadProgress();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (_currentIndex < _total - 1) {
      _goNext();
    } else {
      _showSummary();
    }
  }

  void _goNext() {
    if (_currentIndex >= _total - 1) return;

    _resetCard();
    setState(() => _currentIndex++);
  }

  void _goPrev() {
    if (_currentIndex <= 0) return;

    _resetCard();
    setState(() => _currentIndex--);
  }

  void _resetCard() {
    _flipController.reset();
    setState(() => _isFront = true);
  }

  void _showSummary() {
    final remembered = _sessionAnswers.values.where((value) => value).length;
    final total = _sessionAnswers.length;

    ProgressService.recordActivity(
      userId: _userId,
      activityType: 'flashcard',
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 38),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hoàn thành rồi!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn đã nhớ $remembered/$total từ trong phiên này.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _summaryBox(
                      icon: Icons.check_circle_rounded,
                      value: '$remembered',
                      label: 'Đã nhớ',
                      color: AppColors.success,
                      bgColor: AppColors.successSoft,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryBox(
                      icon: Icons.cancel_rounded,
                      value: '${total - remembered}',
                      label: 'Chưa nhớ',
                      color: AppColors.error,
                      bgColor: AppColors.errorSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentIndex = 0;
                          _sessionAnswers.clear();
                          _resetCard();
                        });
                      },
                      child: const Text('Học lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Xong'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vocabularies.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildEmptyHeader(),
              const Expanded(
                child: Center(
                  child: Text(
                    'Không có từ vựng để học.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
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
            _buildCompactStats(),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * pi;
                      final isFrontVisible = angle < pi / 2;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: isFrontVisible
                            ? _buildFrontCard()
                            : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _buildBackCard(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildBottomArea(),
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
              'Flashcard',
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
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flashcard',
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
          tween: Tween(begin: 0, end: _pageProgress),
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

  Widget _buildCompactStats() {
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
              icon: Icons.menu_book_rounded,
              value: '$_learnedCount',
              label: 'Đã học',
              color: AppColors.primary,
              bgColor: AppColors.primarySoft,
            ),
            const SizedBox(width: 6),
            _miniStat(
              icon: Icons.check_circle_rounded,
              value: '$_rememberedCount',
              label: 'Đã nhớ',
              color: AppColors.success,
              bgColor: AppColors.successSoft,
            ),
            const SizedBox(width: 6),
            _miniStat(
              icon: Icons.refresh_rounded,
              value: '${_total - _rememberedCount}',
              label: 'Còn lại',
              color: AppColors.warning,
              bgColor: AppColors.warningSoft,
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

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.26),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 22,
            top: 22,
            child: _cardPill(
              text: 'FRONT',
              color: Colors.white,
              bgColor: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            top: 22,
            right: 22,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 80, 28, 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nhấn để xem nghĩa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _current.word,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  if (_current.phonetic != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _current.phonetic!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (_current.partOfSpeech != null)
                    _cardPill(
                      text: _current.partOfSpeech!,
                      color: Colors.white,
                      bgColor: Colors.white.withValues(alpha: 0.16),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.075),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 22,
            top: 22,
            child: _cardPill(
              text: 'BACK',
              color: AppColors.success,
              bgColor: AppColors.successSoft,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 82, 28, 42),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: AppColors.success,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Nghĩa tiếng Việt',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _current.meaningVi,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      height: 1.16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (_current.exampleEn != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.borderSoft,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ví dụ',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _current.exampleEn!,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              height: 1.42,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (_current.exampleVi != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _current.exampleVi!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
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

  Widget _cardPill({
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.borderSoft.withValues(alpha: 0.9),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatusChip()),
              const SizedBox(width: 10),
              _buildSpeakButton(),
            ],
          ),
          const SizedBox(height: 14),
          _buildActionButtons(),
          _buildNavRow(),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final status = _currentStatus;

    if (status == null) {
      return Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderSoft,
            width: 1,
          ),
        ),
        child: const Text(
          'Chưa đánh dấu',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final color = status ? AppColors.success : AppColors.error;
    final bgColor = status ? AppColors.successSoft : AppColors.errorSoft;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status ? 'Đã nhớ từ này' : 'Chưa nhớ từ này',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSpeakButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _speak,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.volume_up_rounded,
              color: AppColors.primary,
              size: 19,
            ),
            SizedBox(width: 6),
            Text(
              'Phát âm',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _markWord(false),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Chưa nhớ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _markWord(true),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Đã nhớ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _navButton(
            text: '‹ Trước',
            enabled: _currentIndex > 0,
            onTap: _goPrev,
          ),
          Expanded(
            child: Center(
              child: Text(
                '${_currentIndex + 1}/$_total',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _navButton(
            text: 'Tiếp ›',
            enabled: _currentIndex < _total - 1,
            onTap: _goNext,
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required String text,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            color: enabled ? AppColors.textSecondary : Colors.transparent,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}