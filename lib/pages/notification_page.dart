import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ForUMHUB/models/notification_model.dart';
import 'package:ForUMHUB/services/notification_service.dart';
import 'package:ForUMHUB/pages/post_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notifService = NotificationService();

  Future<void> _handleNotifTap(AppNotification notif) async {
    // 1. Mark as read immediately when tapped
    if (notif.isNew) {
      await _notifService.markAsRead(notif.id);
    }

    if (notif.postId == null || notif.postId!.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post reference missing.')));
      return;
    }

    try {
      // 2. Fetch the latest post data to ensure navigation is accurate
      final postDoc = await FirebaseFirestore.instance.collection('posts').doc(notif.postId).get();
      if (!postDoc.exists) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post no longer exists')));
        return;
      }

      final data = postDoc.data() as Map<String, dynamic>;
      
      if (mounted) {
        // 3. Navigate to the post detail
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailPage(
          postId: postDoc.id,
          title: data['title'] ?? '',
          author: data['authorName'] ?? 'User',
          authorId: data['authorId'] ?? '',
          authorPhotoUrl: data['authorPhotoUrl'],
          course: data['course'] ?? 'General',
          category: data['category'] ?? 'General',
          timestamp: 'Just now',
          description: data['description'] ?? '',
          upvotes: data['upvotes'] ?? 0,
        )));
      }
    } catch (e) {
      debugPrint('Notif Tap Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          TextButton(onPressed: () => _notifService.markAllAsRead(), child: const Text('Mark all read', style: TextStyle(color: Color(0xFFFB8C00)))),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _notifService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final allNotifs = snapshot.data ?? [];
          if (allNotifs.isEmpty) return _buildEmptyState();

          final newNotifs = allNotifs.where((n) => n.isNew).toList();
          final earlierNotifs = allNotifs.where((n) => !n.isNew).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (newNotifs.isNotEmpty) ...[_buildHeader('New'), ...newNotifs.map((n) => _buildNotificationTile(n))],
              if (earlierNotifs.isNotEmpty) ...[_buildHeader('Earlier'), ...earlierNotifs.map((n) => _buildNotificationTile(n))],
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)));
  }

  Widget _buildNotificationTile(AppNotification notif) {
    return Container(
      color: notif.isNew ? const Color(0xFFFB8C00).withOpacity(0.05) : Colors.transparent,
      child: ListTile(
        onTap: () => _handleNotifTap(notif),
        leading: Container(
          width: 50, height: 50,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF5F5F5)),
          child: ClipOval(
            child: notif.avatarUrl != null && notif.avatarUrl!.isNotEmpty
                ? Image.network(notif.avatarUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey, size: 30))
                : const Icon(Icons.person, color: Colors.grey, size: 30),
          ),
        ),
        title: Text(notif.title, style: TextStyle(fontWeight: notif.isNew ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notif.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(height: 4),
            Row(
              children: [
                _getIcon(notif.type, size: 14),
                const SizedBox(width: 4),
                Text(timeago.format(notif.timeAgo.toDate()), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
          onSelected: (value) async {
            if (value == 'read') {
              await _notifService.markAsRead(notif.id);
            } else if (value == 'delete') {
              await _notifService.deleteNotification(notif.id);
            }
          },
          itemBuilder: (context) => [
            if (notif.isNew) const PopupMenuItem(value: 'read', child: Text('Mark as read')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _getIcon(NotificationType type, {double size = 24}) {
    IconData iconData = Icons.notifications; Color iconColor = Colors.grey;
    switch (type) {
      case NotificationType.upvoted: iconData = Icons.arrow_upward; iconColor = Colors.red; break;
      case NotificationType.commented: iconData = Icons.chat_bubble; iconColor = Colors.blue; break;
      case NotificationType.bookmarked: iconData = Icons.bookmark; iconColor = Colors.orange; break;
    }
    return Icon(iconData, color: iconColor, size: size);
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), const Text('All caught up!', style: TextStyle(color: Colors.grey, fontSize: 16))]));
  }
}
