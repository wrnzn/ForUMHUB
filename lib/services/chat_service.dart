import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ForUMHUB/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final CollectionReference _chatCollection = FirebaseFirestore.instance.collection('chats');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FIXED: Using local filtering to avoid the Index error (FAILED_PRECONDITION)
  Stream<List<ChatItemModel>> getConversations([String? query]) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    // We only filter by participants in the database
    return _chatCollection
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatItemModel.fromFirestore(doc)).toList();
      
      // Filter by name LOCALLY to avoid needing a composite index
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        return chats.where((chat) => chat.name.toLowerCase().contains(lowerQuery)).toList();
      }
      
      return chats;
    });
  }

  Future<void> deleteSelfChats() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;
    final query = await _chatCollection.where('participants', arrayContains: currentUserId).get();
    for (var doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      final participants = List<String>.from(data?['participants'] ?? []);
      if (participants.length < 2 || (participants.length == 2 && participants[0] == participants[1])) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> deleteConversation(String chatId) async {
    final messages = await _chatCollection.doc(chatId).collection('messages').get();
    for (var doc in messages.docs) await doc.reference.delete();
    await _chatCollection.doc(chatId).delete();
  }

  Future<Map<String, dynamic>?> getChatDocument(String chatId) async {
    try {
      final doc = await _chatCollection.doc(chatId).get();
      if (doc.exists) return doc.data() as Map<String, dynamic>?;
    } catch (e) { debugPrint('Error: $e'); }
    return null;
  }
}
