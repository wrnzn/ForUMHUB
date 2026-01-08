import 'package:cloud_firestore/cloud_firestore.dart';

class ChatItemModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final String? avatarUrl;
  final int unreadCount;

  ChatItemModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.avatarUrl,
    this.unreadCount = 0,
  });

  factory ChatItemModel.fromFirestore(DocumentSnapshot doc) {
    try {
      if (!doc.exists) {
        return ChatItemModel(
          id: doc.id,
          name: 'Unknown Chat',
          lastMessage: '',
          time: '',
          unreadCount: 0,
        );
      }
      final data = doc.data();
      if (data == null) {
        return ChatItemModel(
          id: doc.id,
          name: 'Unknown Chat',
          lastMessage: '',
          time: '',
          unreadCount: 0,
        );
      }
      final mapData = data as Map<String, dynamic>;
      
      // If name is missing, try to get it from participants
      String name = mapData['name']?.toString() ?? '';
      if (name.isEmpty) {
        // Try to get name from participants (would need user service)
        name = 'Chat';
      }
      
      return ChatItemModel(
        id: doc.id,
        name: name,
        lastMessage: mapData['lastMessage']?.toString() ?? '',
        time: mapData['time']?.toString() ?? '',
        avatarUrl: mapData['avatarUrl']?.toString(),
        unreadCount: (mapData['unreadCount'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      return ChatItemModel(
        id: doc.id,
        name: 'Error loading chat',
        lastMessage: '',
        time: '',
        unreadCount: 0,
      );
    }
  }
}
