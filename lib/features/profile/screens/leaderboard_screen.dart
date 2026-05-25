import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/supabase_service.dart';
import '../models/leaderboard_user_model.dart';
import '../services/leaderboard_service.dart';
import '../services/profile_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<_LeaderboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_LeaderboardData> _loadData() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để xem bảng xếp hạng');
    }

    final profile = await ProfileService.getProfile(userId);

    if (!profile.isPremium) {
      return _LeaderboardData(
        isPremium: false,
        users: const [],
      );
    }

    final users = await LeaderboardService.getLeaderboard();

    return _LeaderboardData(
      isPremium: true,
      users: users,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadData();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<_LeaderboardData>(
        future: _future,
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeader(),
                if (snapshot.connectionState == ConnectionState.waiting)
                  SliverToBoxAdapter(child: _buildLoading())
                else if (snapshot.hasError)
                  SliverToBoxAdapter(
                    child: _buildError(snapshot.error.toString()),
                  )
                else if (snapshot.data?.isPremium == false)
                    SliverToBoxAdapter(child: _buildPremiumLocked())
                  else if ((snapshot.data?.users ?? []).isEmpty)
                      SliverToBoxAdapter(child: _buildEmpty())
                    else ...[
                        SliverToBoxAdapter(
                          child: _buildTopThree(snapshot.data!.users),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          sliver: SliverList.builder(
                            itemCount: snapshot.data!.users.length,
                            itemBuilder: (context, index) {
                              final user = snapshot.data!.users[index];
                              return _buildRankCard(user);
                            },
                          ),
                        ),
                      ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.indigo,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 48,
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(6, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(
            Icons.error_outline_rounded,
            size: 72,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tải được bảng xếp hạng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          _GradientButton(
            text: 'Thử lại',
            icon: Icons.refresh_rounded,
            onTap: _refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLocked() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              gradient: AppColors.amberGradient,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 58,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Leaderboard dành cho Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nâng cấp Premium để xem thứ hạng, điểm số và streak của những người học khác.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _GradientButton(
            text: 'Nâng cấp Premium',
            icon: Icons.lock_open_rounded,
            onTap: () {
              // Sau khi có PremiumScreen thì mở dòng này:
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PremiumScreen sẽ được nối ở phase Premium'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(height: 80),
          Icon(
            Icons.leaderboard_rounded,
            size: 76,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu xếp hạng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy làm quiz để bắt đầu ghi điểm.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree(List<LeaderboardUserModel> users) {
    final topUsers = users.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top learners',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(topUsers.length, (index) {
                final user = topUsers[index];
                final isFirst = user.rank == 1;

                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(
                      vertical: isFirst ? 20 : 14,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isFirst
                          ? AppColors.amberGradient
                          : AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _rankEmoji(user.rank),
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        _Avatar(user: user, size: isFirst ? 58 : 48),
                        const SizedBox(height: 10),
                        Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user.totalScore} điểm',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCard(LeaderboardUserModel user) {
    final isMe = user.id == SupabaseService.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isMe ? AppColors.indigo.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMe
              ? AppColors.indigo.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              user.rank <= 3 ? _rankEmoji(user.rank) : '#${user.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: user.rank <= 3 ? 24 : 15,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _Avatar(user: user, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (user.isPremium) ...[
                      const SizedBox(width: 4),
                      const Text('👑'),
                    ],
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.indigo,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Bạn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.totalQuizzes} quiz • ${user.currentStreak} ngày streak',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.totalScore}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.indigo,
                ),
              ),
              const Text(
                'điểm',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  String _rankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}

class _Avatar extends StatelessWidget {
  final LeaderboardUserModel user;
  final double size;

  const _Avatar({
    required this.user,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.indigo.withValues(alpha: 0.12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Initials(user: user),
      )
          : _Initials(user: user),
    );
  }
}

class _Initials extends StatelessWidget {
  final LeaderboardUserModel user;

  const _Initials({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        user.initials,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: AppColors.indigo,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.indigo.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardData {
  final bool isPremium;
  final List<LeaderboardUserModel> users;

  const _LeaderboardData({
    required this.isPremium,
    required this.users,
  });
}