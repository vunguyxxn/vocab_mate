import '../../../services/supabase_service.dart';
import '../models/leaderboard_user_model.dart';

class LeaderboardService {
  static Future<List<LeaderboardUserModel>> getLeaderboard({
    int limit = 30,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select(
        'id, full_name, avatar_url, total_score, total_quizzes, current_streak, is_premium',
      )
          .order('total_score', ascending: false)
          .order('total_quizzes', ascending: false)
          .limit(limit);

      final rows = List<Map<String, dynamic>>.from(response);

      return List.generate(rows.length, (index) {
        return LeaderboardUserModel.fromMap(
          rows[index],
          rank: index + 1,
        );
      });
    } catch (e) {
      throw Exception('Không thể tải bảng xếp hạng: $e');
    }
  }
}