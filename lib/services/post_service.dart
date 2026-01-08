import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/models/notification_model.dart';
import 'package:ForUMHUB/services/notification_service.dart';
import 'package:ForUMHUB/services/user_service.dart';

class PostService {
  final CollectionReference _postCollection = FirebaseFirestore.instance.collection('posts');
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference _commentCollection = FirebaseFirestore.instance.collection('comments');
  final NotificationService _notifService = NotificationService();
  final UserService _userService = UserService();

  Stream<List<Post>> getPosts() {
    return _postCollection.orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Post>> getPostsByUser(String userId) {
    return _postCollection.where('authorId', isEqualTo: userId).orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Post>> getBookmarkedPosts(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _userCollection.doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return [];
      final data = userDoc.data() as Map<String, dynamic>?;
      List<String> ids = List<String>.from(data?['bookmarked_posts'] ?? []);
      if (ids.isEmpty) return [];
      final snapshots = await Future.wait(ids.map((id) => _postCollection.doc(id).get()));
      return snapshots.where((d) => d.exists).map((d) => Post.fromFirestore(d)).toList();
    });
  }

  Future<void> addPost(String title, String description, String authorName, String category, String authorId, List<String> avatarUrls, {String? authorPhotoUrl, String? course}) async {
    await _postCollection.add({
      'title': title, 'description': description, 'authorName': authorName, 'authorId': authorId,
      'authorPhotoUrl': authorPhotoUrl, 'category': category, 'course': course, 'timestamp': Timestamp.now(),
      'upvotes': 0, 'commentCount': 0, 'upvotedBy': [], 'bookmarkedBy': [], 'avatarUrls': avatarUrls,
    });
  }

  Future<void> deletePost(String postId) async {
    final comments = await _commentCollection.where('postId', isEqualTo: postId).get();
    for (var c in comments.docs) await c.reference.delete();
    await _postCollection.doc(postId).delete();
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await _commentCollection.doc(commentId).delete();
    await _postCollection.doc(postId).update({'commentCount': FieldValue.increment(-1)});
  }

  Future<void> updateComment(String commentId, String newText) async {
    await _commentCollection.doc(commentId).update({'text': newText});
  }

  Future<void> toggleUpvote(String postId, String userId) async {
    final ref = _postCollection.doc(postId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    List upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
    if (upvotedBy.contains(userId)) {
      await ref.update({'upvotes': FieldValue.increment(-1), 'upvotedBy': FieldValue.arrayRemove([userId])});
    } else {
      await ref.update({'upvotes': FieldValue.increment(1), 'upvotedBy': FieldValue.arrayUnion([userId])});
      final senderName = await _userService.getUserName(userId);
      final senderPhoto = (await _userService.getUserData(userId))?['photoUrl'];
      await _notifService.sendNotification(targetUserId: data['authorId'] ?? '', title: 'New Upvote!', subtitle: '$senderName liked your post', type: NotificationType.upvoted, avatarUrl: senderPhoto, postId: postId);
    }
  }

  Future<void> toggleCommentUpvote(String commentId, String userId) async {
    final ref = _commentCollection.doc(commentId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    List upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
    if (upvotedBy.contains(userId)) {
      await ref.update({'upvotes': FieldValue.increment(-1), 'upvotedBy': FieldValue.arrayRemove([userId])});
    } else {
      await ref.update({'upvotes': FieldValue.increment(1), 'upvotedBy': FieldValue.arrayUnion([userId])});
    }
  }

  // FIXED: Now notifies both Post Author AND Comment Author (if reply)
  Future<void> addComment(String postId, String text, String authorName, String authorId, {String? parentId, String? imageUrl}) async {
    await _commentCollection.add({
      'postId': postId, 'text': text, 'authorName': authorName, 'authorId': authorId,
      'parentId': parentId, 'imageUrl': imageUrl, 'timestamp': Timestamp.now(), 'upvotes': 0, 'upvotedBy': [],
    });
    
    final postDoc = await _postCollection.doc(postId).get();
    final postData = postDoc.data() as Map<String, dynamic>?;
    await _postCollection.doc(postId).update({'commentCount': FieldValue.increment(1)});

    final senderPhoto = (await _userService.getUserData(authorId))?['photoUrl'];

    // 1. Notify Post Author
    if (postData != null) {
      await _notifService.sendNotification(
        targetUserId: postData['authorId'], 
        title: 'New Comment!', 
        subtitle: '$authorName commented on your post', 
        type: NotificationType.commented, 
        avatarUrl: senderPhoto, 
        postId: postId,
      );
    }

    // 2. Notify Parent Comment Author (if this is a reply)
    if (parentId != null) {
      final parentDoc = await _commentCollection.doc(parentId).get();
      final parentData = parentDoc.data() as Map<String, dynamic>?;
      if (parentData != null && parentData['authorId'] != postData?['authorId']) {
        await _notifService.sendNotification(
          targetUserId: parentData['authorId'],
          title: 'New Reply!',
          subtitle: '$authorName replied to your comment',
          type: NotificationType.commented,
          avatarUrl: senderPhoto,
          postId: postId,
        );
      }
    }
  }

  Stream<List<Map<String, dynamic>>> getComments(String postId) {
    return _commentCollection.where('postId', isEqualTo: postId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, 'text': data['text'] ?? '', 'authorName': data['authorName'] ?? '',
          'authorId': data['authorId'] ?? '', 'parentId': data['parentId'],
          'imageUrl': data['imageUrl'], 'timestamp': data['timestamp'], 'upvotes': data['upvotes'] ?? 0,
          'upvotedBy': data['upvotedBy'] ?? [],
        };
      }).toList();
    });
  }

  Future<bool> isUpvoted(String postId, String userId) async {
    final doc = await _postCollection.doc(postId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>?;
    return (List.from(data?['upvotedBy'] ?? [])).contains(userId);
  }

  Future<bool> isCommentUpvoted(String commentId, String userId) async {
    final doc = await _commentCollection.doc(commentId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>?;
    return (List.from(data?['upvotedBy'] ?? [])).contains(userId);
  }

  Future<bool> isBookmarked(String postId, String userId) async {
    final doc = await _userCollection.doc(userId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>?;
    return (List.from(data?['bookmarked_posts'] ?? [])).contains(postId);
  }

  Future<void> toggleBookmark(String postId, String userId) async {
    final postDoc = await _postCollection.doc(postId).get();
    final postData = postDoc.data() as Map<String, dynamic>?;
    final userDoc = await _userCollection.doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    List bookmarks = List.from(userData?['bookmarked_posts'] ?? []);
    if (bookmarks.contains(postId)) {
      bookmarks.remove(postId);
    } else {
      bookmarks.add(postId);
      if (postData != null) {
        final senderName = userData?['name'] ?? 'Someone';
        final senderPhoto = userData?['photoUrl'];
        await _notifService.sendNotification(
          targetUserId: postData['authorId'], title: 'Post Bookmarked!', subtitle: '$senderName saved your post',
          type: NotificationType.bookmarked, avatarUrl: senderPhoto, postId: postId,
        );
      }
    }
    await _userCollection.doc(userId).set({'bookmarked_posts': bookmarks}, SetOptions(merge: true));
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _postCollection.doc(postId).update(data);
  }
}
