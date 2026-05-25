import '../../vocabulary/models/vocabulary_model.dart';

enum QuestionType { wordToMeaning, meaningToWord }

class QuizQuestion {
  final VocabularyModel vocabulary;
  final QuestionType type;
  final String questionText;
  final String correctAnswer;
  final List<String> options; // 4 đáp án đã shuffle

  QuizQuestion({
    required this.vocabulary,
    required this.type,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
  });
}