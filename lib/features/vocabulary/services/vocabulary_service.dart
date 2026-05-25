import '../../../services/supabase_service.dart';
import '../../../core/constants/supabase_tables.dart';
import '../models/vocabulary_model.dart';

class VocabularyService {
  static final _client = SupabaseService.client;

  static Future<List<VocabularyModel>> getByTopic(String topicId) async {
    try {
      final data = await _client
          .from(SupabaseTables.vocabularies)
          .select()
          .eq('topic_id', topicId)
          .order('created_at');
      return (data as List).map((e) => VocabularyModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Không thể tải từ vựng');
    }
  }

  // Tạo từ vựng mới
  static Future<VocabularyModel> createVocabulary({
    required String topicId,
    required String userId,
    required String word,
    required String meaningVi,
    String? phonetic,
    String? partOfSpeech,
    String? exampleEn,
    String? exampleVi,
    String difficultyLevel = 'medium',
  }) async {
    try {
      final data = await _client
          .from(SupabaseTables.vocabularies)
          .insert({
        'topic_id': topicId,
        'word': word.trim().toLowerCase(),
        'meaning_vi': meaningVi.trim(),
        'phonetic': phonetic,
        'part_of_speech': partOfSpeech,
        'example_en': exampleEn,
        'example_vi': exampleVi,
        'difficulty_level': difficultyLevel,
        'created_by': userId,
        'source_type': 'user',
      })
          .select()
          .single();
      return VocabularyModel.fromJson(data);
    } catch (e) {
      throw Exception('Không thể thêm từ vựng (từ có thể đã tồn tại)');
    }
  }

// Sửa từ vựng
  static Future<void> updateVocabulary({
    required String vocabId,
    required String word,
    required String meaningVi,
    String? phonetic,
    String? partOfSpeech,
    String? exampleEn,
    String? exampleVi,
    String difficultyLevel = 'medium',
  }) async {
    try {
      await _client.from(SupabaseTables.vocabularies).update({
        'word': word.trim().toLowerCase(),
        'meaning_vi': meaningVi.trim(),
        'phonetic': phonetic,
        'part_of_speech': partOfSpeech,
        'example_en': exampleEn,
        'example_vi': exampleVi,
        'difficulty_level': difficultyLevel,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', vocabId);
    } catch (e) {
      throw Exception('Không thể cập nhật từ vựng');
    }
  }

// Xóa từ vựng
  static Future<void> deleteVocabulary(String vocabId) async {
    try {
      await _client
          .from(SupabaseTables.vocabularies)
          .delete()
          .eq('id', vocabId);
    } catch (e) {
      throw Exception('Không thể xóa từ vựng');
    }
  }

// Tìm kiếm từ vựng
  static Future<List<VocabularyModel>> searchVocabularies({
    required String query,
    String? userId,
  }) async {
    try {
      var q = _client
          .from(SupabaseTables.vocabularies)
          .select('*, topics!inner(visibility, created_by)')
          .or('word.ilike.%$query%,meaning_vi.ilike.%$query%');

      final data = await q.limit(30);

      // Filter: system topics + topic của user
      return (data as List)
          .where((row) {
        final topic = row['topics'];
        return topic['visibility'] == 'system' ||
            (userId != null && topic['created_by'] == userId);
      })
          .map((e) => VocabularyModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm');
    }
  }
}