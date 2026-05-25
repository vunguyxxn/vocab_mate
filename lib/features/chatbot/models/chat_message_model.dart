import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool isLoading;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    required this.isLoading,
  });

  factory ChatMessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    final rawCreatedAt = data['createdAt'];

    return ChatMessageModel(
      id: doc.id,
      role: data['role']?.toString() ?? 'assistant',
      content: data['content']?.toString() ?? '',
      createdAt: rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : DateTime.now(),
      isLoading: data['isLoading'] == true,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}