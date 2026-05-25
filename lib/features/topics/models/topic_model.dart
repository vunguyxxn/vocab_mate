class TopicModel {
  final String id;
  final String title;
  final String? description;
  final String? iconName;
  final String? imageUrl;
  final int displayOrder;
  final bool isActive;
  final String? createdBy;
  final String visibility;
  final String sourceType;
  final bool isPremiumOnly;
  final DateTime createdAt;

  TopicModel({
    required this.id,
    required this.title,
    this.description,
    this.iconName,
    this.imageUrl,
    this.displayOrder = 0,
    this.isActive = true,
    this.createdBy,
    this.visibility = 'system',
    this.sourceType = 'system',
    this.isPremiumOnly = false,
    required this.createdAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    iconName: json['icon_name'],
    imageUrl: json['image_url'],
    displayOrder: json['display_order'] ?? 0,
    isActive: json['is_active'] ?? true,
    createdBy: json['created_by'],
    visibility: json['visibility'] ?? 'system',
    sourceType: json['source_type'] ?? 'system',
    isPremiumOnly: json['is_premium_only'] ?? false,
    createdAt: DateTime.parse(json['created_at']),
  );

  String get emoji {
    switch (iconName) {
      case 'food': return '🍜';
      case 'travel': return '✈️';
      case 'school': return '📚';
      case 'work': return '💼';
      case 'health': return '❤️';
      case 'technology': return '💻';
      default: return '📖';
    }
  }
}