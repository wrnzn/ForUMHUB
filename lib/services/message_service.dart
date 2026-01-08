import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ForUMHUB/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      final currentUserId = _auth.currentUser?.uid ?? '';
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel(
          senderId: data['senderId'] ?? '',
          text: data['text'] ?? '',
          imageUrl: data['imageUrl'],
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isMe: (data['senderId'] ?? '') == currentUserId,
        );
      }).toList();
    });
  }

  Future<void> sendMessage(String chatId, String text, {String? imageUrl}) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUserId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': imageUrl != null ? '📷 Image' : text,
      'time': DateTime.now().toString(),
      'unreadCount': FieldValue.increment(1),
      'lastSenderId': currentUserId,
    });
  }

  Future<String> getOrCreateChatId(String otherUserId, {String? otherUserName}) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || currentUserId == otherUserId) return '';

    final query = await _firestore.collection('chats')
        .where('participants', arrayContains: currentUserId).get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(otherUserId)) return doc.id;
    }

    final chatRef = await _firestore.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'name': otherUserName ?? 'Chat',
      'lastMessage': '',
      'time': DateTime.now().toString(),
      'unreadCount': 0,
      'lastSenderId': '',
    });
    return chatRef.id;
  }

  Future<void> markAsRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount': 0,
    });
  }

  Future<void> deleteConversation(String chatId) async {
    final messages = await _firestore.collection('chats').doc(chatId).collection('messages').get();
    for (var doc in messages.docs) await doc.reference.delete();
    await _firestore.collection('chats').doc(chatId).delete();
  }
}
