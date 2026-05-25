import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/supabase_service.dart';
import '../models/notification_model.dart';

class NotificationFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _itemsRef(String userId) {
    return _firestore.collection('notifications').doc(userId).collection('items');
  }

  static Stream<List<NotificationModel>> watchNotifications() {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để xem thông báo');
    }

    return _itemsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(NotificationModel.fromFirestore).toList();
    });
  }

  static Future<void> createNotification({
    required String title,
    required String body,
    String type = 'general',
  }) async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để tạo thông báo');
    }

    await _itemsRef(userId).add({
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> markAsRead(String notificationId) async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để cập nhật thông báo');
    }

    await _itemsRef(userId).doc(notificationId).update({
      'isRead': true,
    });
  }

  static Future<void> markAllAsRead() async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để cập nhật thông báo');
    }

    final snapshot = await _itemsRef(userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
      });
    }

    await batch.commit();
  }

  static Future<void> deleteNotification(String notificationId) async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để xoá thông báo');
    }

    await _itemsRef(userId).doc(notificationId).delete();
  }

  static Future<void> seedDemoNotificationsIfEmpty() async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để tạo thông báo demo');
    }

    final snapshot = await _itemsRef(userId).limit(1).get();

    if (snapshot.docs.isNotEmpty) return;

    final batch = _firestore.batch();

    final first = _itemsRef(userId).doc();
    final second = _itemsRef(userId).doc();
    final third = _itemsRef(userId).doc();

    batch.set(first, {
      'title': 'Chào mừng đến với VocabMate',
      'body': 'Hãy học 10 từ mới hôm nay để duy trì streak nhé.',
      'type': 'welcome',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(second, {
      'title': 'Gợi ý học tập',
      'body': 'Bạn có thể luyện flashcard trước khi làm quiz để nhớ lâu hơn.',
      'type': 'learning',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(third, {
      'title': 'Premium',
      'body': 'Nâng cấp Premium để mở khóa chatbot AI không giới hạn và bảng xếp hạng.',
      'type': 'premium',
      'isRead': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}