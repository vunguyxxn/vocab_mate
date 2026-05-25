import 'dart:math';
import '../../../services/supabase_service.dart';
import '../../../core/constants/supabase_tables.dart';
import '../../vocabulary/models/vocabulary_model.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_attempt_model.dart';

class QuizService {
  static final _client = SupabaseService.client;
  static final _random = Random();

  // Tạo danh sách câu hỏi
  static List<QuizQuestion> generateQuestions(
      List<VocabularyModel> vocabs, {
        int? maxQuestions,
      }) {
    if (vocabs.length < 4) return [];

    final shuffled = List<VocabularyModel>.from(vocabs)..shuffle(_random);
    final selected = maxQuestions != null
        ? shuffled.take(maxQuestions).toList()
        : shuffled;

    return selected.map((vocab) {
      final type = _random.nextBool()
          ? QuestionType.wordToMeaning
          : QuestionType.meaningToWord;

      final questionText = type == QuestionType.wordToMeaning
          ? vocab.word
          : vocab.meaningVi;

      final correctAnswer = type == QuestionType.wordToMeaning
          ? vocab.meaningVi
          : vocab.word;

      // Lấy 3 đáp án sai từ các từ khác
      final others = vocabs.where((v) => v.id != vocab.id).toList()
        ..shuffle(_random);
      final wrongAnswers = others.take(3).map((v) {
        return type == QuestionType.wordToMeaning ? v.meaningVi : v.word;
      }).toList();

      final options = [...wrongAnswers, correctAnswer]..shuffle(_random);

      return QuizQuestion(
        vocabulary: vocab,
        type: type,
        questionText: questionText,
        correctAnswer: correctAnswer,
        options: options,
      );
    }).toList();
  }

  // Lưu kết quả quiz
  static Future<QuizAttemptModel> submitQuiz({
    required String topicId,
    required List<QuizQuestion> questions,
    required Map<int, String> userAnswers, // index → selected answer
    required int durationSeconds,
  }) async {
    final userId = SupabaseService.currentUserId!;
    final total = questions.length;
    int correct = 0;

    // Tính số đúng
    for (int i = 0; i < total; i++) {
      if (userAnswers[i] == questions[i].correctAnswer) correct++;
    }

    final accuracy = total > 0 ? (correct / total * 100) : 0.0;
    final score = correct * 10;

    // Insert quiz_attempt
    final attemptData = await _client
        .from(SupabaseTables.quizAttempts)
        .insert({
      'user_id': userId,
      'topic_id': topicId,
      'total_questions': total,
      'correct_answers': correct,
      'score': score,
      'accuracy': accuracy,
      'duration_seconds': durationSeconds,
    })
        .select()
        .single();

    final attemptId = attemptData['id'];

    // Insert quiz_answers
    final answers = List.generate(total, (i) => {
      'quiz_attempt_id': attemptId,
      'vocabulary_id': questions[i].vocabulary.id,
      'question_type': questions[i].type == QuestionType.wordToMeaning
          ? 'word_to_meaning'
          : 'meaning_to_word',
      'question_text': questions[i].questionText,
      'correct_answer': questions[i].correctAnswer,
      'selected_answer': userAnswers[i] ?? '',
      'is_correct': userAnswers[i] == questions[i].correctAnswer,
    });

    await _client.from(SupabaseTables.quizAnswers).insert(answers);

    // Cộng điểm vào profiles
    await _client.rpc('increment_score', params: {
      'user_id_param': userId,
      'score_param': score,
    });

    // Record activity
    await _client.from(SupabaseTables.learningActivities).upsert(
      {
        'user_id': userId,
        'activity_date': DateTime.now().toIso8601String().substring(0, 10),
        'activity_type': 'quiz',
      },
      onConflict: 'user_id,activity_date',
    );

    return QuizAttemptModel.fromJson(attemptData);
  }
}