class QuizAttemptModel {
  final String id;
  final String userId;
  final String topicId;
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final double accuracy;
  final int durationSeconds;
  final DateTime createdAt;

  QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.accuracy,
    required this.durationSeconds,
    required this.createdAt,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      QuizAttemptModel(
        id: json['id'],
        userId: json['user_id'],
        topicId: json['topic_id'],
        totalQuestions: json['total_questions'],
        correctAnswers: json['correct_answers'],
        score: json['score'],
        accuracy: (json['accuracy'] as num).toDouble(),
        durationSeconds: json['duration_seconds'],
        createdAt: DateTime.parse(json['created_at']),
      );
}