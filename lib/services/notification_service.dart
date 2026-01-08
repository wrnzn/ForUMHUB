import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ForUMHUB/models/notification_model.dart';

class NotificationService {
  final CollectionReference _notificationCollection = FirebaseFirestore.instance.collection('notifications');

  Stream<List<AppNotification>> getNotifications() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _notificationCollection
        .where('targetUserId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList();
          list.sort((a, b) => b.timeAgo.compareTo(a.timeAgo));
          return list;
        });
  }

  // NEW: Mark single notification as read
  Future<void> markAsRead(String notifId) async {
    await _notificationCollection.doc(notifId).update({'isNew': false});
  }

  // NEW: Delete a single notification
  Future<void> deleteNotification(String notifId) async {
    await _notificationCollection.doc(notifId).delete();
  }

  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String subtitle,
    required NotificationType type,
    String? avatarUrl,
    String? postId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == targetUserId) return;

    await _notificationCollection.add({
      'targetUserId': targetUserId,
      'title': title,
      'subtitle': subtitle,
      'type': type.toString().split('.').last,
      'timeAgo': Timestamp.now(),
      'avatarUrl': avatarUrl,
      'postId': postId,
      'isNew': true,
      'senderId': currentUserId,
    });
  }

  Future<void> markAllAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final query = await _notificationCollection
        .where('targetUserId', isEqualTo: userId)
        .where('isNew', isEqualTo: true)
        .get();

    for (var doc in query.docs) {
      await doc.reference.update({'isNew': false});
    }
  }
}
