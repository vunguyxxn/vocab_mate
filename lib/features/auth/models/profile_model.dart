class ProfileModel {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final int totalScore;
  final int totalQuizzes;
  final int currentStreak;
  final int longestStreak;
  final bool isPremium;
  final String? fcmToken;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.totalScore = 0,
    this.totalQuizzes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isPremium = false,
    this.fcmToken,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      totalScore: _toInt(json['total_score']),
      totalQuizzes: _toInt(json['total_quizzes']),
      currentStreak: _toInt(json['current_streak']),
      longestStreak: _toInt(json['longest_streak']),
      isPremium: json['is_premium'] == true,
      fcmToken: json['fcm_token']?.toString(),
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'].toString()),
    );
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'total_score': totalScore,
      'total_quizzes': totalQuizzes,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'is_premium': isPremium,
      'fcm_token': fcmToken,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String get initials {
    final name = fullName.trim();

    if (name.isEmpty) {
      return 'U';
    }

    final parts = name.split(RegExp(r'\s+'));

    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }

    return name[0].toUpperCase();
  }
}