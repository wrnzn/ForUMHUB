import 'package:flutter/material.dart';
import 'package:ForUMHUB/pages/post_detail_page.dart';
import 'package:ForUMHUB/pages/edit_post_page.dart';
import 'package:ForUMHUB/pages/profile_page.dart';
import 'package:ForUMHUB/widgets/course_utils.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePostCardFixed extends StatefulWidget {
  final String title;
  final String author;
  final String authorId;
  final String? authorPhotoUrl;
  final String course;
  final String category;
  final String timestamp;
  final String description;
  final int upvotes;
  final int bookmarks;
  final int commentCount;
  final String postId;
  final List<String>? postImages;

  const HomePostCardFixed({
    super.key,
    required this.title,
    required this.author,
    required this.authorId,
    this.authorPhotoUrl,
    required this.course,
    required this.category,
    required this.timestamp,
    required this.description,
    required this.upvotes,
    required this.bookmarks,
    required this.commentCount,
    required this.postId,
    this.postImages,
  });

  @override
  State<HomePostCardFixed> createState() => _HomePostCardFixedState();
}

class _HomePostCardFixedState extends State<HomePostCardFixed> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  bool _isBookmarked = false;
  bool _isUpvoted = false;
  bool _isAdmin = false;
  int _upvoteCount = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _upvoteCount = widget.upvotes;
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (_currentUserId != null) {
      final isBookmarked = await _postService.isBookmarked(widget.postId, _currentUserId!);
      final isUpvoted = await _postService.isUpvoted(widget.postId, _currentUserId!);
      final isAdmin = await _userService.isAdmin(_currentUserId!);
      if (mounted) setState(() { 
        _isBookmarked = isBookmarked; 
        _isUpvoted = isUpvoted;
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canManage = _isAdmin || _currentUserId == widget.authorId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailPage(
            postId: widget.postId, 
            title: widget.title, 
            author: widget.author, 
            authorId: widget.authorId,
            authorPhotoUrl: widget.authorPhotoUrl, 
            course: widget.course, 
            category: widget.category, 
            timestamp: widget.timestamp, 
            description: widget.description, 
            upvotes: _upvoteCount,
          )));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              categoryBadge(widget.category),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildAuthorAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(child: Text(widget.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            courseChip(widget.course),
                          ],
                        ),
                        Text(widget.timestamp, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                  _buildMenu(canManage),
                ],
              ),
              const SizedBox(height: 16),
              Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 8),
              Text(widget.description, style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
              
              if (widget.postImages != null && widget.postImages!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPostImages(),
              ],
              
              const SizedBox(height: 16),
              _buildInteractionBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: widget.author))),
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _userService.getUserDataStream(widget.authorId),
        builder: (context, snapshot) {
          final String? photo = snapshot.data?['photoUrl'];
          return Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF5F5F5)),
            child: ClipOval(child: photo != null ? Image.network(photo, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person, color: Colors.grey)) : const Icon(Icons.person, color: Colors.grey)),
          );
        },
      ),
    );
  }

  Widget _buildPostImages() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.postImages!.length,
          itemBuilder: (c, i) => Container(
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(right: 10),
            child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(widget.postImages![i], fit: BoxFit.cover)),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(bool canManage) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'delete') _handleDelete();
        else if (value == 'edit') Navigator.push(context, MaterialPageRoute(builder: (context) => EditPostPage(postId: widget.postId, initialTitle: widget.title, initialDescription: widget.description, initialCategory: widget.category)));
        else if (value == 'save') _toggleBookmark();
      },
      itemBuilder: (context) => [
        if (canManage) const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (canManage) const PopupMenuItem(value: 'delete', child: Text('Delete')),
        PopupMenuItem(value: 'save', child: Text(_isBookmarked ? 'Unsave Post' : 'Save Post')),
      ],
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
    );
  }

  Widget _buildInteractionBar() {
    return Row(
      children: [
        _buildPill(Icons.arrow_upward, '$_upvoteCount', _isUpvoted ? const Color(0xFFFB8C00) : Colors.grey, _toggleUpvote),
        const SizedBox(width: 12),
        _buildPill(Icons.comment_outlined, '${widget.commentCount}', Colors.grey, null),
        const Spacer(),
        IconButton(
          icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _isBookmarked ? const Color(0xFFFB8C00) : Colors.grey, size: 22),
          onPressed: _toggleBookmark,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildPill(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  Future<void> _handleDelete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete Post?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes'))]));
    if (ok == true) await _postService.deletePost(widget.postId);
  }

  Future<void> _toggleUpvote() async {
    if (_currentUserId == null) return;
    setState(() { _isUpvoted ? _upvoteCount-- : _upvoteCount++; _isUpvoted = !_isUpvoted; });
    await _postService.toggleUpvote(widget.postId, _currentUserId!);
  }

  Future<void> _toggleBookmark() async {
    if (_currentUserId == null) return;
    await _postService.toggleBookmark(widget.postId, _currentUserId!);
    setState(() { _isBookmarked = !_isBookmarked; });
  }
}
