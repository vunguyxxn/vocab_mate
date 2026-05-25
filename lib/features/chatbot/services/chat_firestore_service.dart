import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/supabase_service.dart';
import '../../profile/services/profile_service.dart';
import '../models/chat_message_model.dart';
import 'ai_chat_service.dart';

class ChatFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _sessions =>
      _firestore.collection('chat_sessions');

  static Future<String> getOrCreateSession() async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để dùng chatbot');
    }

    final existing = await _sessions
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final session = await _sessions.add({
      'userId': userId,
      'title': 'VocabMate AI',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await session.collection('messages').add({
      'userId': userId,
      'role': 'assistant',
      'content':
      'Xin chào 👋 Mình là VocabMate AI. Bạn muốn học từ vựng, ngữ pháp hay luyện ví dụ tiếng Anh?',
      'createdAt': FieldValue.serverTimestamp(),
      'isLoading': false,
    });

    return session.id;
  }

  static Stream<List<ChatMessageModel>> watchMessages(String sessionId) {
    return _sessions
        .doc(sessionId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(ChatMessageModel.fromFirestore).toList();
    });
  }

  static Future<bool> canSendMessageToday(String sessionId) async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để dùng chatbot');
    }

    final profile = await ProfileService.getProfile(userId);

    if (profile.isPremium) {
      return true;
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _sessions
        .doc(sessionId)
        .collection('messages')
        .where('role', isEqualTo: 'user')
        .get();

    final todayUserMessages = snapshot.docs.where((doc) {
      final data = doc.data();

      if (data['userId'] != userId) return false;

      final createdAt = data['createdAt'];

      if (createdAt is! Timestamp) return false;

      final date = createdAt.toDate();

      return date.isAfter(startOfDay) || date.isAtSameMomentAs(startOfDay);
    }).length;

    return todayUserMessages < 10;
  }

  static Future<void> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      throw Exception('Bạn cần đăng nhập để dùng chatbot');
    }

    final trimmed = message.trim();

    if (trimmed.isEmpty) return;

    final canSend = await canSendMessageToday(sessionId);

    if (!canSend) {
      throw Exception(
        'Tài khoản Free chỉ được gửi 10 tin nhắn AI mỗi ngày. Hãy nâng cấp Premium để dùng không giới hạn.',
      );
    }

    final sessionRef = _sessions.doc(sessionId);
    final messagesRef = sessionRef.collection('messages');

    DocumentReference<Map<String, dynamic>>? loadingDoc;

    try {
      await messagesRef.add({
        'userId': userId,
        'role': 'user',
        'content': trimmed,
        'createdAt': FieldValue.serverTimestamp(),
        'isLoading': false,
      });

      loadingDoc = await messagesRef.add({
        'userId': userId,
        'role': 'assistant',
        'content': 'Đang suy nghĩ...',
        'createdAt': FieldValue.serverTimestamp(),
        'isLoading': true,
      });

      await sessionRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final reply = await AiChatService.ask(trimmed);
      await loadingDoc.update({
        'content': reply,
        'createdAt': FieldValue.serverTimestamp(),
        'isLoading': false,
      });

      await sessionRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (loadingDoc != null) {
        await loadingDoc.update({
          'content': errorMessage,
          'createdAt': FieldValue.serverTimestamp(),
          'isLoading': false,
        });
      }

      throw Exception(errorMessage);
    }
  }

  static Future<void> clearSession(String sessionId) async {
    final messages = await _sessions.doc(sessionId).collection('messages').get();

    final batch = _firestore.batch();

    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }

    batch.update(_sessions.doc(sessionId), {
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}