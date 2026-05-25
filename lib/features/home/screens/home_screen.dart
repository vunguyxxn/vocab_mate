import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/supabase_service.dart';
import '../../auth/models/profile_model.dart';
import '../../notification/screens/notification_screen.dart';
import '../../premium/screens/premium_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/services/profile_service.dart';
import '../../topics/models/topic_model.dart';
import '../../topics/screens/create_topic_screen.dart';
import '../../topics/screens/topic_detail_screen.dart';
import '../../topics/screens/topic_list_screen.dart';
import '../../topics/services/topic_service.dart';
import '../../vocabulary/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProfileModel? _profile;
  List<TopicModel> _topics = [];
  Map<String, int> _rememberedMap = {};
  Map<String, int> _vocabCountMap = {};
  bool _loading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final userId = SupabaseService.currentUserId;

      if (userId == null) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }

      await ProfileService.updateStreak(userId);

      final profile = await ProfileService.getProfile(userId);
      final topics = await TopicService.getSystemTopics();
      final topicIds = topics.map((topic) => topic.id).toList();

      final rememberedMap = await TopicService.getRememberedCountMap(
        userId,
        topicIds,
      );

      final vocabCountMap = await TopicService.getVocabCountMap(topicIds);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _topics = topics;
        _rememberedMap = rememberedMap;
        _vocabCountMap = vocabCountMap;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  int get _totalRemembered {
    return _rememberedMap.values.fold(0, (sum, value) => sum + value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(),
      body: _selectedTab == 0 ? _buildHome() : const ProfileScreen(),
    );
  }

  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: _loading ? _buildShimmer() : _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 104,
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
            child: _buildHeaderTopRow(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderTopRow() {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VocabMate',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _profile?.isPremium == true ? 'Premium learner' : 'Free learner',
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
        _headerIconButton(
          icon: Icons.search_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _headerIconButton(
          icon: Icons.notifications_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        _headerIconButton(
          icon: Icons.add_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateTopicScreen(),
              ),
            ).then((result) {
              if (result == true) {
                _loadData();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _profile?.initials ?? 'U',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
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
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(),
          const SizedBox(height: 18),
          _buildDailyGoalCard(),
          const SizedBox(height: 26),
          _buildSectionHeader(
            title: 'Chủ đề từ vựng',
            actionText: 'Xem tất cả',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TopicListScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
          const SizedBox(height: 14),
          _buildTopicGrid(),
          const SizedBox(height: 26),
          const Text(
            'Tiến độ của bạn',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 14),
          _buildProgressStats(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
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
            color: Colors.black.withValues(alpha: 0.075),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumBadge(),
          const SizedBox(height: 12),
          const Text(
            'Xin chào 👋',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _profile?.fullName ?? 'Bạn ơi',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildHeroStatCard(
                icon: Icons.local_fire_department_rounded,
                value: '${_profile?.currentStreak ?? 0}',
                label: 'Streak',
                color: AppColors.warning,
                bgColor: AppColors.warningSoft,
              ),
              const SizedBox(width: 10),
              _buildHeroStatCard(
                icon: Icons.bolt_rounded,
                value: '${_profile?.totalScore ?? 0}',
                label: 'Điểm',
                color: AppColors.primary,
                bgColor: AppColors.primarySoft,
              ),
              const SizedBox(width: 10),
              _buildHeroStatCard(
                icon: Icons.auto_stories_rounded,
                value: '$_totalRemembered',
                label: 'Đã nhớ',
                color: AppColors.success,
                bgColor: AppColors.successSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadge() {
    final isPremium = _profile?.isPremium ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPremium ? AppColors.warningSoft : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.workspace_premium_rounded : Icons.school_rounded,
            color: isPremium ? AppColors.warning : AppColors.primary,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            isPremium ? 'Premium' : 'Free learner',
            style: TextStyle(
              color: isPremium ? AppColors.warning : AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    const goal = 10;
    final learned = _totalRemembered.clamp(0, goal);
    final progress = learned / goal;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mục tiêu hôm nay',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Duy trì thói quen học mỗi ngày',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$learned/$goal',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 800),
              builder: (_, value, __) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  backgroundColor: AppColors.surface,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            learned >= goal
                ? 'Bạn đã hoàn thành mục tiêu hôm nay.'
                : 'Còn ${goal - learned} từ nữa để hoàn thành mục tiêu.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (_topics.isNotEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TopicDetailScreen(topic: _topics.first),
                  ),
                ).then((_) => _loadData());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(17),
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
                    'Học ngay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicGrid() {
    final displayTopics = _topics.take(4).toList();

    if (displayTopics.isEmpty) {
      return _buildEmptyTopics();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.35,
      ),
      itemCount: displayTopics.length,
      itemBuilder: (context, index) {
        final topic = displayTopics[index];
        final isPremiumLocked =
            topic.isPremiumOnly && !(_profile?.isPremium ?? false);
        final remembered = _rememberedMap[topic.id] ?? 0;
        final total = _vocabCountMap[topic.id] ?? 0;

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: isPremiumLocked
              ? _showPremiumDialog
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicDetailScreen(topic: topic),
              ),
            ).then((_) => _loadData());
          },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isPremiumLocked ? 0.82 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _topicSoftColor(index),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            topic.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isPremiumLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    topic.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremiumLocked ? 'Cần Premium' : '$remembered/$total từ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPremiumLocked
                          ? AppColors.warning
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : (remembered / total).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: AppColors.borderSoft,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPremiumLocked ? AppColors.warning : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildProgressStats() {
    final hasQuiz = (_profile?.totalQuizzes ?? 0) > 0;

    final accuracy = hasQuiz
        ? '${((_profile!.totalScore / (_profile!.totalQuizzes * 10)) * 100).clamp(0, 100).toStringAsFixed(0)}%'
        : '—';

    return Row(
      children: [
        _buildStatBox(
          icon: Icons.auto_stories_rounded,
          value: '$_totalRemembered',
          label: 'Từ đã nhớ',
          color: AppColors.primary,
          bgColor: AppColors.primarySoft,
        ),
        const SizedBox(width: 10),
        _buildStatBox(
          icon: Icons.track_changes_rounded,
          value: '${_profile?.totalQuizzes ?? 0}',
          label: 'Quiz done',
          color: AppColors.success,
          bgColor: AppColors.successSoft,
        ),
        const SizedBox(width: 10),
        _buildStatBox(
          icon: Icons.insights_rounded,
          value: accuracy,
          label: 'Chính xác',
          color: AppColors.warning,
          bgColor: AppColors.warningSoft,
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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

  Widget _buildEmptyTopics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.borderSoft,
          width: 1,
        ),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Chưa có chủ đề',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hãy tạo chủ đề đầu tiên để bắt đầu học từ vựng.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 150),
      child: Column(
        children: List.generate(
          4,
              (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 92,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderSoft,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _navItem(
              0,
              Icons.home_rounded,
              Icons.home_outlined,
              'Trang chủ',
            ),
            _navItem(
              1,
              Icons.person_rounded,
              Icons.person_outline,
              'Hồ sơ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
      int index,
      IconData activeIcon,
      IconData inactiveIcon,
      String label,
      ) {
    final isActive = _selectedTab == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          setState(() {
            _selectedTab = index;
          });

          if (index == 0) {
            await _loadData();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Mở khoá Premium',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Nâng cấp Premium để mở khoá tất cả chủ đề và tính năng.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Để sau'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                final upgraded = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => const PremiumScreen(),
                  ),
                );

                if (upgraded == true) {
                  await _loadData();
                }
              },
              child: const Text(
                'Nâng cấp',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}