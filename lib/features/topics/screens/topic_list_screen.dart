import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/supabase_service.dart';
import '../models/topic_model.dart';
import '../services/topic_service.dart';
import 'topic_detail_screen.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({super.key});

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  List<TopicModel> _topics = [];
  Map<String, int> _rememberedMap = {};
  Map<String, int> _vocabCountMap = {};
  bool _loading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final userId = SupabaseService.currentUserId!;
      final topics = await TopicService.getSystemTopics();
      final topicIds = topics.map((topic) => topic.id).toList();

      final rememberedMap = await TopicService.getRememberedCountMap(
        userId,
        topicIds,
      );

      final vocabCountMap = await TopicService.getVocabCountMap(topicIds);

      final profileData = await SupabaseService.client
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .single();

      if (!mounted) return;

      setState(() {
        _topics = topics;
        _rememberedMap = rememberedMap;
        _vocabCountMap = vocabCountMap;
        _isPremium = profileData['is_premium'] ?? false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final freeCount = _topics.where((topic) => !topic.isPremiumOnly).length;
    final premiumCount = _topics.where((topic) => topic.isPremiumOnly).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _buildSummaryCard(
                  totalCount: _topics.length,
                  freeCount: freeCount,
                  premiumCount: premiumCount,
                ),
              ),
            ),
            if (_loading)
              SliverToBoxAdapter(child: _buildShimmer())
            else if (_topics.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return _buildTopicCard(
                        topic: _topics[index],
                        index: index,
                      );
                    },
                    childCount: _topics.length,
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
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chủ đề từ vựng',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Chọn chủ đề để bắt đầu học',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
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
          color: AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required int totalCount,
    required int freeCount,
    required int premiumCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            icon: Icons.layers_rounded,
            value: '$totalCount',
            label: 'Chủ đề',
            color: AppColors.primary,
            bgColor: AppColors.primarySoft,
          ),
          const SizedBox(width: 10),
          _buildSummaryItem(
            icon: Icons.lock_open_rounded,
            value: '$freeCount',
            label: 'Miễn phí',
            color: AppColors.success,
            bgColor: AppColors.successSoft,
          ),
          const SizedBox(width: 10),
          _buildSummaryItem(
            icon: Icons.workspace_premium_rounded,
            value: '$premiumCount',
            label: 'VIP',
            color: AppColors.warning,
            bgColor: AppColors.warningSoft,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
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
                fontSize: 17,
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

  Widget _buildTopicCard({
    required TopicModel topic,
    required int index,
  }) {
    final isPremiumLocked = topic.isPremiumOnly && !_isPremium;
    final remembered = _rememberedMap[topic.id] ?? 0;
    final total = _vocabCountMap[topic.id] ?? 0;
    final progress = total > 0 ? (remembered / total).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: isPremiumLocked
            ? _showPremiumDialog
            : () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, animation, __) {
                return TopicDetailScreen(topic: topic);
              },
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          ).then((_) => _loadData());
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isPremiumLocked ? 0.84 : 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.borderSoft,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _topicSoftColor(index),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          topic.emoji,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  topic.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.cardTitle.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildBadge(
                                text: isPremiumLocked ? 'VIP' : 'FREE',
                                bgColor: isPremiumLocked
                                    ? AppColors.warningSoft
                                    : AppColors.successSoft,
                                textColor: isPremiumLocked
                                    ? AppColors.warning
                                    : AppColors.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            topic.description ?? 'Bộ từ vựng tiếng Anh cơ bản.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isPremiumLocked
                            ? AppColors.warningSoft
                            : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isPremiumLocked
                            ? Icons.lock_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: isPremiumLocked
                            ? AppColors.warning
                            : AppColors.textSecondary,
                        size: isPremiumLocked ? 18 : 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (isPremiumLocked)
                  _buildLockedBox()
                else
                  _buildProgressBox(
                    remembered: remembered,
                    total: total,
                    progress: progress,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildProgressBox({
    required int remembered,
    required int total,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.primary,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                '$remembered/$total từ đã nhớ',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              builder: (_, value, __) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: AppColors.borderSoft,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 0.6 ? AppColors.success : AppColors.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.warning,
            size: 17,
          ),
          SizedBox(width: 7),
          Text(
            'Cần Premium để mở khoá',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _topicSoftColor(int index) {
    final colors = [
      AppColors.primarySoft,
      AppColors.successSoft,
      AppColors.warningSoft,
      AppColors.blueSoft,
      AppColors.pinkSoft,
      AppColors.purpleSoft,
    ];

    return colors[index % colors.length];
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: List.generate(
          5,
              (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 124,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.layers_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có chủ đề nào',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Danh sách chủ đề sẽ hiển thị ở đây khi có dữ liệu.',
              textAlign: TextAlign.center,
              style: TextStyle(
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

  void _showPremiumDialog() {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Mở khoá Premium',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Nâng cấp Premium để mở khoá tất cả chủ đề cao cấp.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Đã hiểu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}