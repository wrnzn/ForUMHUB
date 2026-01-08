import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Search users by name
  Stream<List<Map<String, dynamic>>> searchUsers(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    final currentUserId = _auth.currentUser?.uid ?? '';
    
    return _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId) // Exclude current user
          .map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'course': data['course'] ?? '',
          'avatarUrl': data['avatarUrl'],
        };
      }).toList();
    });
  }

  // Get all users (for browsing)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    final currentUserId = _auth.currentUser?.uid ?? '';
    
    return _firestore
        .collection('users')
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'course': data['course'] ?? '',
          'avatarUrl': data['avatarUrl'],
        };
      }).toList();
    });
  }
}
