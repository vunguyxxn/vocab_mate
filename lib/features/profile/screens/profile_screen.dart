import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/supabase_service.dart';
import '../../auth/models/profile_model.dart';
import '../../auth/services/auth_service.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../services/profile_service.dart';
import 'leaderboard_screen.dart';
import '../../premium/screens/premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel? _profile;
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final userId = SupabaseService.currentUserId!;

      await ProfileService.updateStreak(userId);

      final profile = await ProfileService.getProfile(userId);
      final stats = await ProfileService.getLearningStats(userId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Đăng xuất?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
    }
  }

  Future<void> _editName() async {
    final ctrl = TextEditingController(
      text: _profile?.fullName ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Đổi tên',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'Nhập tên mới',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text(
              'Lưu',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ProfileService.updateName(
        userId: SupabaseService.currentUserId!,
        fullName: result,
      );

      _loadData();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.indigo,
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.indigo,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStreakCard(),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                    const SizedBox(height: 16),
                    _buildWeeklyActivity(),
                    const SizedBox(height: 16),
                    _buildMenuSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => SliverAppBar(
    expandedHeight: 220,
    pinned: true,
    backgroundColor: const Color(0xFF4F46E5),
    automaticallyImplyLeading: false,
    actions: [
      GestureDetector(
        onTap: _logout,
        child: Container(
          margin: const EdgeInsets.only(
            right: 16,
            top: 8,
            bottom: 8,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.logout,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _profile?.initials ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  if (_profile?.isPremium == true)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '👑',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _editName,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _profile?.fullName ?? 'Người dùng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit_rounded,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Supabase.instance.client.auth.currentUser?.email ?? '',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              if (_profile?.isPremium == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '👑 Premium Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildStreakCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: AppColors.amberGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        const Text(
          '🔥',
          style: TextStyle(fontSize: 44),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${_profile?.currentStreak ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ngày liên tiếp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                'Kỷ lục: ${_profile?.longestStreak ?? 0} ngày',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _profile?.currentStreak == 0 ? 'Học ngay!' : 'Tiếp tục!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStatsGrid() {
    final remembered = _stats['rememberedCount'] ?? 0;
    final learned = _stats['learnedCount'] ?? 0;
    final accuracy = (_stats['avgAccuracy'] as double? ?? 0).toStringAsFixed(1);
    final quizzes = _profile?.totalQuizzes ?? 0;
    final score = _profile?.totalScore ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: [
        _statBox('📚', '$remembered', 'Đã nhớ', AppColors.indigo),
        _statBox('✏️', '$learned', 'Đã học', AppColors.success),
        _statBox('🎯', '$accuracy%', 'Chính xác', AppColors.warning),
        _statBox('📝', '$quizzes', 'Quiz done', const Color(0xFFEC4899)),
        _statBox('⚡', '$score', 'Tổng điểm', AppColors.indigo),
        _statBox(
          '🏆',
          '${_profile?.longestStreak ?? 0}',
          'Kỷ lục',
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _statBox(
      String emoji,
      String value,
      String label,
      Color color,
      ) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildWeeklyActivity() {
    final activeDates = List<String>.from(_stats['weeklyActivities'] ?? []);
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 Hoạt động 7 ngày qua',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final date = now.subtract(Duration(days: 6 - i));
              final dateStr =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

              final isActive = activeDates.contains(dateStr);
              final isToday = i == 6;
              final weekday = date.weekday;
              final label = days[weekday - 1];

              return Column(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.primaryGradient : null,
                      color: isActive ? null : AppColors.background,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                        color: AppColors.indigo,
                        width: 2,
                      )
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? const Text(
                        '🔥',
                        style: TextStyle(fontSize: 16),
                      )
                          : Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppColors.indigo
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        _menuItem(
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: 'Nâng cấp Premium',
          subtitle: _profile?.isPremium == true
              ? 'Đang dùng Premium 👑'
              : 'Mở khoá tất cả tính năng',
          onTap: () async {
            final upgraded = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => const PremiumScreen(),
              ),
            );

            if (upgraded == true) {
              await _loadData();
            }
          },
          showArrow: _profile?.isPremium != true,
        ),
        _divider(),

        _menuItem(
          icon: Icons.smart_toy_rounded,
          iconColor: AppColors.indigo,
          title: 'VocabMate AI',
          subtitle: _profile?.isPremium == true
              ? 'Chatbot AI không giới hạn'
              : '10 tin nhắn mỗi ngày',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChatbotScreen(),
              ),
            );
          },
        ),

        _divider(),

        _menuItem(
          icon: Icons.leaderboard_rounded,
          iconColor: AppColors.indigo,
          title: 'Bảng xếp hạng',
          subtitle: _profile?.isPremium == true
              ? 'Xem thứ hạng người học'
              : 'Premium only',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LeaderboardScreen(),
              ),
            );
          },
        ),

        _divider(),

        _menuItem(
          icon: Icons.edit_rounded,
          iconColor: AppColors.indigo,
          title: 'Đổi tên hiển thị',
          subtitle: _profile?.fullName ?? '',
          onTap: _editName,
        ),

        _divider(),

        _menuItem(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.textSecondary,
          title: 'Về ứng dụng',
          subtitle: 'VocabMate v1.0.0',
          onTap: () {},
        ),

        _divider(),

        _menuItem(
          icon: Icons.logout_rounded,
          iconColor: AppColors.error,
          title: 'Đăng xuất',
          subtitle: Supabase.instance.client.auth.currentUser?.email ?? '',
          onTap: _logout,
          showArrow: false,
        ),
      ],
    ),
  );

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
              ],
            ),
          ),
        ),
      );

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey.shade100,
    indent: 72,
  );
}