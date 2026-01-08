import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() => _auth.currentUser;

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) { return null; }
  }

  Future<bool> isAdmin(String userId) async {
    try {
      final data = await getUserData(userId);
      return data?['role'] == 'admin';
    } catch (e) { return false; }
  }

  // NEW: Find user by name
  Future<String?> getUserIdByName(String name) async {
    try {
      final query = await _firestore.collection('users')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();
      return query.docs.isNotEmpty ? query.docs.first.id : null;
    } catch (e) { return null; }
  }

  Stream<Map<String, dynamic>?> getUserDataStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) => doc.exists ? doc.data() : null);
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  Future<String> getUserName(String userId) async {
    final userData = await getUserData(userId);
    return userData?['name'] ?? 'User';
  }
}
