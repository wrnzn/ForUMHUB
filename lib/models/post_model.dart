import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post {
  final String id;
  final String authorName;
  final String authorId;
  final String? authorPhotoUrl;
  final String category;
  final String? course; // Added course field
  final Timestamp timestamp;
  final String title;
  final String description;
  final int upvotes;
  final int bookmarks;
  final int commentCount;
  final List<String> avatarUrls; // This stores the post images

  Post({
    required this.id,
    required this.authorName,
    required this.authorId,
    this.authorPhotoUrl,
    required this.category,
    this.course,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.upvotes,
    required this.bookmarks,
    required this.commentCount,
    required this.avatarUrls,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) throw Exception('Null data');
      
      return Post(
        id: doc.id,
        authorName: data['authorName']?.toString() ?? '',
        authorId: data['authorId']?.toString() ?? '',
        authorPhotoUrl: data['authorPhotoUrl']?.toString(),
        category: data['category']?.toString() ?? '',
        course: data['course']?.toString(), // Parse course
        timestamp: data['timestamp'] is Timestamp ? data['timestamp'] as Timestamp : Timestamp.now(),
        title: data['title']?.toString() ?? '',
        description: data['description']?.toString() ?? '',
        upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
        bookmarks: (data['bookmarks'] as num?)?.toInt() ?? 0,
        commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
        // FIXED: Ensure we read post images correctly
        avatarUrls: data['avatarUrls'] is List ? List<String>.from(data['avatarUrls'] as List) : [],
      );
    } catch (e) {
      return Post(
        id: doc.id, authorName: 'Unknown', authorId: '', category: '', timestamp: Timestamp.now(),
        title: 'Error', description: '', upvotes: 0, bookmarks: 0, commentCount: 0, avatarUrls: [],
      );
    }
  }

  String get formattedTimestamp => timeago.format(timestamp.toDate());
}
