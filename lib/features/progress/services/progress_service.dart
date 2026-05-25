import '../../../services/supabase_service.dart';
import '../../../core/constants/supabase_tables.dart';
import '../models/user_word_progress_model.dart';

class ProgressService {
  static final _client = SupabaseService.client;

  static Future<Map<String, UserWordProgressModel>> getProgressMap(
      String userId, List<String> vocabularyIds) async {
    if (vocabularyIds.isEmpty) return {};
    try {
      final data = await _client
          .from(SupabaseTables.userWordProgress)
          .select()
          .eq('user_id', userId)
          .filter('vocabulary_id', 'in', '(${vocabularyIds.join(',')})');

      final Map<String, UserWordProgressModel> result = {};
      for (final row in data as List) {
        final model = UserWordProgressModel.fromJson(row);
        result[model.vocabularyId] = model;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> markWord({
    required String userId,
    required String vocabularyId,
    required bool isRemembered,
  }) async {
    await _client.from(SupabaseTables.userWordProgress).upsert(
      {
        'user_id': userId,
        'vocabulary_id': vocabularyId,
        'is_remembered': isRemembered,
        'status': isRemembered ? 'mastered' : 'learning',
        'last_reviewed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,vocabulary_id',
    );
  }

  static Future<void> recordActivity({
    required String userId,
    required String activityType,
  }) async {
    await _client.from(SupabaseTables.learningActivities).upsert(
      {
        'user_id': userId,
        'activity_date': DateTime.now().toIso8601String().substring(0, 10),
        'activity_type': activityType,
      },
      onConflict: 'user_id,activity_date',
    );
  }
}