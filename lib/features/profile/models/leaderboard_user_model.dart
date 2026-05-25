class LeaderboardUserModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final int totalScore;
  final int totalQuizzes;
  final int currentStreak;
  final bool isPremium;
  final int rank;

  LeaderboardUserModel({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.totalScore,
    required this.totalQuizzes,
    required this.currentStreak,
    required this.isPremium,
    required this.rank,
  });

  factory LeaderboardUserModel.fromMap(
      Map<String, dynamic> map, {
        required int rank,
      }) {
    return LeaderboardUserModel(
      id: map['id'] as String,
      fullName: (map['full_name'] ?? 'User') as String,
      avatarUrl: map['avatar_url'] as String?,
      totalScore: (map['total_score'] ?? 0) as int,
      totalQuizzes: (map['total_quizzes'] ?? 0) as int,
      currentStreak: (map['current_streak'] ?? 0) as int,
      isPremium: (map['is_premium'] ?? false) as bool,
      rank: rank,
    );
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }
}