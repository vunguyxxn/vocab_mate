import '../../../services/supabase_service.dart';
import '../../../core/constants/supabase_tables.dart';
import '../models/topic_model.dart';

class TopicService {
  static final _client = SupabaseService.client;

  // Lấy tất cả topic hệ thống
  static Future<List<TopicModel>> getSystemTopics() async {
    try {
      final data = await _client
          .from(SupabaseTables.topics)
          .select()
          .eq('visibility', 'system')
          .eq('is_active', true)
          .order('display_order');
      return (data as List).map((e) => TopicModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách chủ đề');
    }
  }

  // Đếm số từ đã nhớ trong topic
  static Future<Map<String, int>> getRememberedCountMap(
      String userId, List<String> topicIds) async {
    try {
      final data = await _client
          .from(SupabaseTables.userWordProgress)
          .select('vocabulary_id, vocabularies!inner(topic_id)')
          .eq('user_id', userId)
          .eq('is_remembered', true)
          .filter('vocabularies.topic_id', 'in', '(${topicIds.join(',')})');

      final Map<String, int> result = {};
      for (final row in data as List) {
        final topicId = row['vocabularies']['topic_id'] as String;
        result[topicId] = (result[topicId] ?? 0) + 1;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  // Đếm tổng số từ mỗi topic
  static Future<Map<String, int>> getVocabCountMap(
      List<String> topicIds) async {
    try {
      final data = await _client
          .from(SupabaseTables.vocabularies)
          .select('topic_id')
          .filter('topic_id', 'in', '(${topicIds.join(',')})');

      final Map<String, int> result = {};
      for (final row in data as List) {
        final topicId = row['topic_id'] as String;
        result[topicId] = (result[topicId] ?? 0) + 1;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  // Lấy topic cá nhân của user
  static Future<List<TopicModel>> getUserTopics(String userId) async {
    try {
      final data = await _client
          .from(SupabaseTables.topics)
          .select()
          .eq('created_by', userId)
          .eq('source_type', 'user')
          .order('created_at', ascending: false);
      return (data as List).map((e) => TopicModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Không thể tải topic cá nhân');
    }
  }

// Tạo topic mới
  static Future<TopicModel> createTopic({
    required String userId,
    required String title,
    String? description,
    String? iconName,
    String visibility = 'private',
  }) async {
    try {
      final data = await _client
          .from(SupabaseTables.topics)
          .insert({
        'title': title,
        'description': description,
        'icon_name': iconName ?? 'custom',
        'created_by': userId,
        'visibility': visibility,
        'source_type': 'user',
        'is_active': true,
        'is_premium_only': false,
      })
          .select()
          .single();
      return TopicModel.fromJson(data);
    } catch (e) {
      throw Exception('Không thể tạo chủ đề');
    }
  }

// Sửa topic
  static Future<void> updateTopic({
    required String topicId,
    required String title,
    String? description,
    String? iconName,
    String? visibility,
  }) async {
    try {
      await _client.from(SupabaseTables.topics).update({
        'title': title,
        'description': description,
        'icon_name': iconName,
        'visibility': visibility,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', topicId);
    } catch (e) {
      throw Exception('Không thể cập nhật chủ đề');
    }
  }

// Xóa topic
  static Future<void> deleteTopic(String topicId) async {
    try {
      await _client
          .from(SupabaseTables.topics)
          .delete()
          .eq('id', topicId);
    } catch (e) {
      throw Exception('Không thể xóa chủ đề');
    }
  }
}