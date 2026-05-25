class VocabularyModel {
  final String id;
  final String topicId;
  final String word;
  final String? phonetic;
  final String? partOfSpeech;
  final String meaningVi;
  final String? exampleEn;
  final String? exampleVi;
  final String? imageUrl;
  final String sourceType;
  final String difficultyLevel;
  final DateTime createdAt;

  VocabularyModel({
    required this.id,
    required this.topicId,
    required this.word,
    this.phonetic,
    this.partOfSpeech,
    required this.meaningVi,
    this.exampleEn,
    this.exampleVi,
    this.imageUrl,
    this.sourceType = 'system',
    this.difficultyLevel = 'medium',
    required this.createdAt,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) =>
      VocabularyModel(
        id: json['id'],
        topicId: json['topic_id'],
        word: json['word'],
        phonetic: json['phonetic'],
        partOfSpeech: json['part_of_speech'],
        meaningVi: json['meaning_vi'],
        exampleEn: json['example_en'],
        exampleVi: json['example_vi'],
        imageUrl: json['image_url'],
        sourceType: json['source_type'] ?? 'system',
        difficultyLevel: json['difficulty_level'] ?? 'medium',
        createdAt: DateTime.parse(json['created_at']),
      );
}