import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/post_detail/post_detail_card.dart';
import 'package:ForUMHUB/widgets/post_detail/comment_item.dart';
import 'package:ForUMHUB/widgets/post_detail/comment_input_box.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/services/file_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailPage extends StatefulWidget {
  final String postId;
  final String title;
  final String author;
  final String authorId;
  final String? authorPhotoUrl;
  final String course;
  final String category; // Added category
  final String timestamp;
  final String description;
  final int upvotes;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.title,
    required this.author,
    required this.authorId,
    this.authorPhotoUrl,
    required this.course,
    required this.category, // Added category
    required this.timestamp,
    required this.description,
    required this.upvotes,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late TextEditingController _commentController;
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final FileService _fileService = FileService();
  
  String? _userName;
  String? _userId;
  String? _replyToId; 
  String? _commentImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _userService.getCurrentUser();
    if (user != null) {
      setState(() { _userId = user.uid; });
      final userData = await _userService.getUserData(user.uid);
      if (mounted) setState(() { _userName = userData?['name'] ?? 'User'; });
    }
  }

  Future<void> _pickCommentImage() async {
    final File? file = await _fileService.pickImage();
    if (file == null) return;
    setState(() => _isUploading = true);
    try {
      final String? url = await _fileService.uploadImage(file);
      if (mounted) setState(() => _commentImageUrl = url);
    } catch (e) {
      debugPrint('Comment Image Error: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _handleReply(Map<String, dynamic> commentData) {
    setState(() {
      _replyToId = commentData['parentId'] ?? commentData['id']; 
      _commentController.text = "@${commentData['authorName']} ";
      _commentController.selection = TextSelection.fromPosition(TextPosition(offset: _commentController.text.length));
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty && _commentImageUrl == null) return;
    if (_userId == null) return;
    try {
      await _postService.addComment(
        widget.postId, _commentController.text.trim(), _userName!, _userId!,
        parentId: _replyToId,
        imageUrl: _commentImageUrl,
      );
      _commentController.clear();
      if (mounted) setState(() { _replyToId = null; _commentImageUrl = null; });
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, centerTitle: true, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)), title: const Text('Discussion', style: TextStyle(color: Color(0xFFFB8C00), fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').doc(widget.postId).snapshots(),
              builder: (context, postSnapshot) {
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _postService.getComments(widget.postId),
                  builder: (context, commentSnapshot) {
                    final postData = postSnapshot.data?.data() as Map<String, dynamic>?;
                    final List<Map<String, dynamic>> allComments = commentSnapshot.data ?? [];
                    final List<Widget> listItems = [];
                    
                    final List<String> pImages = postData?['avatarUrls'] != null ? List<String>.from(postData!['avatarUrls']) : [];

                    listItems.add(PostDetailCard(
                      postId: widget.postId, author: postData?['authorName'] ?? widget.author, authorId: postData?['authorId'] ?? widget.authorId,
                      authorPhotoUrl: postData?['authorPhotoUrl'] ?? widget.authorPhotoUrl, 
                      course: postData?['course'] ?? widget.course, // Pass Course
                      category: postData?['category'] ?? widget.category, // Pass Category
                      timestamp: widget.timestamp, title: postData?['title'] ?? widget.title, description: postData?['description'] ?? widget.description,
                      upvotes: postData?['upvotes'] ?? widget.upvotes,
                      postImages: pImages,
                    ));
                    listItems.add(const SizedBox(height: 12));
                    listItems.add(const Divider());
                    listItems.add(Padding(padding: const EdgeInsets.symmetric(vertical: 12.0), child: Text('Comments (${allComments.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))));

                    final parents = allComments.where((c) => c['parentId'] == null).toList();
                    parents.sort((a, b) => (a['timestamp'] as Timestamp?)?.compareTo(b['timestamp'] as Timestamp? ?? Timestamp.now()) ?? 0);

                    for (var parent in parents) {
                      listItems.add(_buildCommentItem(parent, false));
                      final children = allComments.where((c) => c['parentId'] == parent['id']).toList();
                      children.sort((a, b) => (a['timestamp'] as Timestamp?)?.compareTo(b['timestamp'] as Timestamp? ?? Timestamp.now()) ?? 0);
                      for (var child in children) {
                        listItems.add(Padding(padding: const EdgeInsets.only(left: 40.0), child: _buildCommentItem(child, true)));
                      }
                    }

                    if (allComments.isEmpty && commentSnapshot.connectionState != ConnectionState.waiting) {
                      listItems.add(const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No comments yet.', style: TextStyle(color: Colors.grey)))));
                    }

                    return ListView(padding: const EdgeInsets.all(16), children: listItems);
                  },
                );
              },
            ),
          ),
          if (_commentImageUrl != null) Padding(padding: const EdgeInsets.only(left: 16), child: Stack(children: [Container(width: 80, height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(_commentImageUrl!), fit: BoxFit.cover))), Positioned(top: 0, right: 0, child: GestureDetector(onTap: () => setState(() => _commentImageUrl = null), child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 16))))])),
          CommentInputBox(controller: _commentController, onSend: _submitComment, onPickImage: _pickCommentImage, isUploading: _isUploading),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> data, bool isReply) {
    return CommentItem(
      authorName: data['authorName'] ?? 'User',
      authorId: data['authorId'] ?? '',
      commentId: data['id'] ?? '',
      postId: widget.postId,
      timeAgo: data['timestamp'] != null ? timeago.format((data['timestamp'] as Timestamp).toDate()) : 'Just now',
      text: data['text'] ?? '',
      upvotes: data['upvotes'] ?? 0,
      onReply: () => _handleReply(data),
      commentImageUrl: data['imageUrl'],
    );
  }
}
