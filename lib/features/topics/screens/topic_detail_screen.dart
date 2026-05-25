import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/supabase_service.dart';
import '../../flashcard/screens/flashcard_screen.dart';
import '../../progress/models/user_word_progress_model.dart';
import '../../progress/services/progress_service.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../vocabulary/models/vocabulary_model.dart';
import '../../vocabulary/screens/create_vocabulary_screen.dart';
import '../../vocabulary/services/vocabulary_service.dart';
import '../models/topic_model.dart';
import '../screens/create_topic_screen.dart';
import '../services/topic_service.dart';

class TopicDetailScreen extends StatefulWidget {
  final TopicModel topic;

  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  List<VocabularyModel> _vocabs = [];
  Map<String, UserWordProgressModel> _progressMap = {};
  bool _loading = true;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final userId = SupabaseService.currentUserId!;
      final vocabs = await VocabularyService.getByTopic(widget.topic.id);
      final ids = vocabs.map((vocab) => vocab.id).toList();
      final progressMap = await ProgressService.getProgressMap(userId, ids);

      if (!mounted) return;

      setState(() {
        _vocabs = vocabs;
        _progressMap = progressMap;
        _isOwner = widget.topic.sourceType == 'user' &&
            widget.topic.createdBy == userId;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int get _rememberedCount {
    return _progressMap.values.where((progress) => progress.isRemembered).length;
  }

  double get _progressPercent {
    if (_vocabs.isEmpty) return 0;
    return (_rememberedCount / _vocabs.length).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _isOwner
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateVocabularyScreen(topic: widget.topic),
            ),
          ).then((result) {
            if (result == true) {
              _loadData();
            }
          });
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _buildOverviewCard(),
              ),
            ),
            if (_loading)
              SliverToBoxAdapter(child: _buildShimmer())
            else if (_vocabs.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActionButtons(),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Danh sách từ vựng',
                              style: AppTextStyles.sectionTitle,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.borderSoft,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${_vocabs.length} từ',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _vocabs.length,
                        itemBuilder: (context, index) {
                          return _buildVocabCard(_vocabs[index]);
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 98,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                _circleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isOwner ? 'Chủ đề cá nhân' : 'Chủ đề hệ thống',
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
                if (_isOwner) ...[
                  const SizedBox(width: 8),
                  _circleIconButton(
                    icon: Icons.edit_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CreateTopicScreen(editTopic: widget.topic),
                        ),
                      ).then((result) {
                        if (result == true) {
                          _loadData();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _circleIconButton(
                    icon: Icons.delete_rounded,
                    iconColor: AppColors.error,
                    bgColor: AppColors.errorSoft,
                    onTap: _confirmDeleteTopic,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = AppColors.textPrimary,
    Color bgColor = AppColors.surface,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
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
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.065),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    widget.topic.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.topic.description ?? 'Bộ từ vựng tiếng Anh.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildOverviewStat(
                icon: Icons.auto_stories_rounded,
                value: '${_vocabs.length}',
                label: 'Từ vựng',
                color: AppColors.primary,
                bgColor: AppColors.primarySoft,
              ),
              const SizedBox(width: 10),
              _buildOverviewStat(
                icon: Icons.check_circle_rounded,
                value: '$_rememberedCount',
                label: 'Đã nhớ',
                color: AppColors.success,
                bgColor: AppColors.successSoft,
              ),
              const SizedBox(width: 10),
              _buildOverviewStat(
                icon: _isOwner
                    ? Icons.person_rounded
                    : Icons.verified_rounded,
                value: _isOwner ? 'Bạn' : 'Hệ thống',
                label: 'Nguồn',
                color: AppColors.warning,
                bgColor: AppColors.warningSoft,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progressPercent),
              duration: const Duration(milliseconds: 700),
              builder: (_, value, __) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.borderSoft,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _vocabs.isEmpty
                ? 'Chưa có dữ liệu tiến độ.'
                : 'Bạn đã nhớ $_rememberedCount/${_vocabs.length} từ trong chủ đề này.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 19,
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: value.length > 6 ? 12 : 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
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
            onTap: _vocabs.isNotEmpty
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FlashcardScreen(
                    topic: widget.topic,
                    vocabularies: _vocabs,
                  ),
                ),
              ).then((_) => _loadData());
            }
                : null,
            child: Container(
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.style_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Flashcard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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
            onTap: _vocabs.length < 4
                ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cần ít nhất 4 từ để làm quiz!'),
                ),
              );
            }
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    topic: widget.topic,
                    vocabularies: _vocabs,
                    isPremium: false,
                  ),
                ),
              ).then((_) => _loadData());
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.4,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Quiz',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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

  Widget _buildVocabCard(VocabularyModel vocab) {
    final progress = _progressMap[vocab.id];
    final isRemembered = progress?.isRemembered ?? false;
    final isLearned = progress != null;

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _statusSoftColor(
                isRemembered: isRemembered,
                isLearned: isLearned,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              isRemembered
                  ? Icons.check_rounded
                  : isLearned
                  ? Icons.close_rounded
                  : Icons.text_fields_rounded,
              color: _statusColor(
                isRemembered: isRemembered,
                isLearned: isLearned,
              ),
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocab.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (vocab.phonetic != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    vocab.phonetic!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  vocab.meaningVi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildMini(
                      vocab.partOfSpeech ?? 'n/a',
                      AppColors.primarySoft,
                      AppColors.primary,
                    ),
                    _buildMini(
                      vocab.difficultyLevel,
                      _difficultyBg(vocab.difficultyLevel),
                      _difficultyColor(vocab.difficultyLevel),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _statusSoftColor(
                isRemembered: isRemembered,
                isLearned: isLearned,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isRemembered
                  ? Icons.check_circle_rounded
                  : isLearned
                  ? Icons.cancel_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: _statusColor(
                isRemembered: isRemembered,
                isLearned: isLearned,
              ),
              size: 18,
            ),
          ),
        ],
      ),
    );

    if (!_isOwner) return card;

    return Dismissible(
      key: Key(vocab.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_rounded,
              color: Colors.white,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              'Xóa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async => _confirmDeleteVocab(vocab),
      onDismissed: (_) async {
        await VocabularyService.deleteVocabulary(vocab.id);
        _loadData();
      },
      child: GestureDetector(
        onLongPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateVocabularyScreen(
                topic: widget.topic,
                editVocab: vocab,
              ),
            ),
          ).then((result) {
            if (result == true) {
              _loadData();
            }
          });
        },
        child: card,
      ),
    );
  }

  Color _statusColor({
    required bool isRemembered,
    required bool isLearned,
  }) {
    if (isRemembered) return AppColors.success;
    if (isLearned) return AppColors.error;
    return AppColors.textMuted;
  }

  Color _statusSoftColor({
    required bool isRemembered,
    required bool isLearned,
  }) {
    if (isRemembered) return AppColors.successSoft;
    if (isLearned) return AppColors.errorSoft;
    return AppColors.surfaceSoft;
  }

  Color _difficultyBg(String value) {
    if (value == 'easy') return AppColors.successSoft;
    if (value == 'hard') return AppColors.errorSoft;
    return AppColors.warningSoft;
  }

  Color _difficultyColor(String value) {
    if (value == 'easy') return AppColors.success;
    if (value == 'hard') return AppColors.error;
    return AppColors.warning;
  }

  Widget _buildMini(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteVocab(VocabularyModel vocab) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Xóa từ vựng?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text('Bạn có chắc muốn xóa từ "${vocab.word}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _confirmDeleteTopic() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Xóa chủ đề?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Toàn bộ từ vựng trong chủ đề sẽ bị xóa. Không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != true) return;

    await TopicService.deleteTopic(widget.topic.id);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...List.generate(
            5,
                (_) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.borderSoft,
            width: 1,
          ),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có từ vựng nào',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isOwner
                  ? 'Nhấn nút + để thêm từ vựng đầu tiên.'
                  : 'Chủ đề này hiện chưa có dữ liệu từ vựng.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}