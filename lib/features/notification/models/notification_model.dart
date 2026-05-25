import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    final createdAtRaw = data['createdAt'];
    DateTime createdAt = DateTime.now();

    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    }

    return NotificationModel(
      id: doc.id,
      title: data['title']?.toString() ?? 'Thông báo',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? 'general',
      isRead: data['isRead'] == true,
      createdAt: createdAt,
    );
  }
}