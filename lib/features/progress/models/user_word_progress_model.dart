class UserWordProgressModel {
  final String id;
  final String userId;
  final String vocabularyId;
  final String status;
  final bool isRemembered;
  final int reviewLevel;
  final int correctCount;
  final int wrongCount;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;

  UserWordProgressModel({
    required this.id,
    required this.userId,
    required this.vocabularyId,
    this.status = 'new',
    this.isRemembered = false,
    this.reviewLevel = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.lastReviewedAt,
    required this.createdAt,
  });

  factory UserWordProgressModel.fromJson(Map<String, dynamic> json) =>
      UserWordProgressModel(
        id: json['id'],
        userId: json['user_id'],
        vocabularyId: json['vocabulary_id'],
        status: json['status'] ?? 'new',
        isRemembered: json['is_remembered'] ?? false,
        reviewLevel: json['review_level'] ?? 0,
        correctCount: json['correct_count'] ?? 0,
        wrongCount: json['wrong_count'] ?? 0,
        lastReviewedAt: json['last_reviewed_at'] != null
            ? DateTime.parse(json['last_reviewed_at'])
            : null,
        createdAt: DateTime.parse(json['created_at']),
      );
}