import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/notification_model.dart';
import '../services/notification_firestore_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _seedDemoData();
  }

  Future<void> _seedDemoData() async {
    setState(() {
      _isSeeding = true;
    });

    try {
      await NotificationFirestoreService.seedDemoNotificationsIfEmpty();
    } catch (_) {
      // Không chặn UI nếu seed demo lỗi.
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await NotificationFirestoreService.markAllAsRead();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả là đã đọc'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await NotificationFirestoreService.deleteNotification(id);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await NotificationFirestoreService.markAsRead(notification.id);
    } catch (_) {
      // Không cần báo lỗi nếu chỉ fail mark read.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.indigo,
            actions: [
              IconButton(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all_rounded),
                tooltip: 'Đánh dấu đã đọc',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Thông báo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Lịch sử nhắc học, premium và hoạt động của bạn',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<List<NotificationModel>>(
            stream: NotificationFirestoreService.watchNotifications(),
            builder: (context, snapshot) {
              if (_isSeeding ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList.separated(
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => const _NotificationSkeleton(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: 'Không tải được thông báo',
                    onRetry: _seedDemoData,
                  ),
                );
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    onCreateDemo: _seedDemoData,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    return _NotificationCard(
                      notification: notification,
                      onTap: () => _markAsRead(notification),
                      onDelete: () => _deleteNotification(notification.id),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(notification.type);
    final color = _colorForType(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: AppColors.redGradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.white,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: notification.isRead
                    ? Colors.transparent
                    : AppColors.indigo.withValues(alpha: 0.35),
                width: 1.2,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: notification.isRead
                                    ? FontWeight.w700
                                    : FontWeight.w900,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(top: 5, left: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.indigo,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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

  static IconData _iconForType(String type) {
    switch (type) {
      case 'welcome':
        return Icons.waving_hand_rounded;
      case 'learning':
        return Icons.menu_book_rounded;
      case 'premium':
        return Icons.workspace_premium_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'streak':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'welcome':
        return AppColors.indigo;
      case 'learning':
        return AppColors.success;
      case 'premium':
        return AppColors.warning;
      case 'quiz':
        return AppColors.pinkGradient.colors.first;
      case 'streak':
        return AppColors.error;
      default:
        return AppColors.indigo;
    }
  }

  static String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 13,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 11,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateDemo;

  const _EmptyState({
    required this.onCreateDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              color: AppColors.indigo.withValues(alpha: 0.75),
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có thông báo',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Các nhắc nhở học tập và cập nhật Premium sẽ xuất hiện tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onCreateDemo,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tạo thông báo demo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.indigo,
                side: const BorderSide(color: AppColors.indigo),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy kiểm tra Firestore Rules hoặc kết nối mạng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.indigo,
                side: const BorderSide(color: AppColors.indigo),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}