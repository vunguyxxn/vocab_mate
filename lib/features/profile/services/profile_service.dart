import '../../../services/supabase_service.dart';
import '../../auth/models/profile_model.dart';

class ProfileService {
  static Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('Không thể tải thông tin hồ sơ: $e');
    }
  }

  static Future<void> updateName({
    required String userId,
    required String fullName,
  }) async {
    try {
      await SupabaseService.client.from('profiles').update({
        'full_name': fullName.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Không thể cập nhật tên: $e');
    }
  }

  static Future<void> updateStreak(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('learning_activities')
          .select('activity_date')
          .eq('user_id', userId)
          .order('activity_date', ascending: false);

      final rows = List<Map<String, dynamic>>.from(response);

      if (rows.isEmpty) {
        await SupabaseService.client.from('profiles').update({
          'current_streak': 0,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        return;
      }

      final activeDates = rows
          .map((row) => DateTime.parse(row['activity_date'].toString()))
          .map((date) => DateTime(date.year, date.month, date.day))
          .toSet();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      DateTime checkDate;

      if (activeDates.contains(today)) {
        checkDate = today;
      } else if (activeDates.contains(yesterday)) {
        checkDate = yesterday;
      } else {
        await SupabaseService.client.from('profiles').update({
          'current_streak': 0,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        return;
      }

      int streak = 0;

      while (activeDates.contains(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      final profile = await SupabaseService.client
          .from('profiles')
          .select('longest_streak')
          .eq('id', userId)
          .single();

      final oldLongest = profile['longest_streak'] ?? 0;
      final newLongest = streak > oldLongest ? streak : oldLongest;

      await SupabaseService.client.from('profiles').update({
        'current_streak': streak,
        'longest_streak': newLongest,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Không thể cập nhật streak: $e');
    }
  }

  static Future<Map<String, dynamic>> getLearningStats(String userId) async {
    try {
      final progressRows = await SupabaseService.client
          .from('user_word_progress')
          .select('status, is_remembered')
          .eq('user_id', userId);

      final progressList = List<Map<String, dynamic>>.from(progressRows);

      final rememberedCount = progressList
          .where((item) => item['is_remembered'] == true)
          .length;

      final learnedCount = progressList
          .where((item) {
        final status = item['status']?.toString();
        return status == 'learning' ||
            status == 'reviewing' ||
            status == 'mastered';
      })
          .length;

      final quizRows = await SupabaseService.client
          .from('quiz_attempts')
          .select('accuracy')
          .eq('user_id', userId);

      final quizList = List<Map<String, dynamic>>.from(quizRows);

      double avgAccuracy = 0;

      if (quizList.isNotEmpty) {
        final totalAccuracy = quizList.fold<double>(
          0,
              (sum, item) {
            final value = item['accuracy'];
            if (value == null) return sum;
            return sum + double.tryParse(value.toString())!;
          },
        );

        avgAccuracy = totalAccuracy / quizList.length;
      }

      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 6));

      final startDateStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';

      final activityRows = await SupabaseService.client
          .from('learning_activities')
          .select('activity_date')
          .eq('user_id', userId)
          .gte('activity_date', startDateStr)
          .order('activity_date', ascending: true);

      final activityList = List<Map<String, dynamic>>.from(activityRows);

      final weeklyActivities = activityList
          .map((item) => item['activity_date'].toString())
          .toSet()
          .toList();

      return {
        'rememberedCount': rememberedCount,
        'learnedCount': learnedCount,
        'avgAccuracy': avgAccuracy,
        'weeklyActivities': weeklyActivities,
      };
    } catch (e) {
      throw Exception('Không thể tải thống kê học tập: $e');
    }
  }
}