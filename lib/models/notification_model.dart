import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { commented, upvoted, bookmarked }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final Timestamp timeAgo;
  final String? avatarUrl;
  final String? postId; // Added postId
  bool isNew;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.avatarUrl,
    this.postId, // Added postId
    this.isNew = false,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.upvoted,
      ),
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      timeAgo: data['timeAgo'] ?? Timestamp.now(),
      avatarUrl: data['avatarUrl'],
      postId: data['postId'], // Parse postId
      isNew: data['isNew'] ?? false,
    );
  }
}
