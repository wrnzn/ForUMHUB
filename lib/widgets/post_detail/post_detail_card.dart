import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/course_utils.dart';
import 'package:ForUMHUB/pages/profile_page.dart';
import 'package:ForUMHUB/pages/edit_post_page.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailCard extends StatefulWidget {
  final String postId;
  final String author;
  final String authorId;
  final String? authorPhotoUrl;
  final String course; // User's academic course
  final String category; // Post's tag (General, etc.)
  final String timestamp;
  final String title;
  final String description;
  final int upvotes;
  final List<String>? postImages;

  const PostDetailCard({
    super.key,
    required this.postId,
    required this.author,
    required this.authorId,
    this.authorPhotoUrl,
    required this.course,
    required this.category,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.upvotes,
    this.postImages,
  });

  @override
  State<PostDetailCard> createState() => _PostDetailCardState();
}

class _PostDetailCardState extends State<PostDetailCard> {
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
      if (mounted) {
        setState(() { 
          _isBookmarked = isBookmarked; 
          _isUpvoted = isUpvoted; 
          _isAdmin = isAdmin;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_currentUserId == null) return;
    await _postService.toggleBookmark(widget.postId, _currentUserId!);
    if (mounted) {
      setState(() => _isBookmarked = !_isBookmarked);
    }
  }

  Future<void> _toggleUpvote() async {
    if (_currentUserId == null) return;
    setState(() {
      if (_isUpvoted) {
        _upvoteCount--;
      } else {
        _upvoteCount++;
      }
      _isUpvoted = !_isUpvoted;
    });
    await _postService.toggleUpvote(widget.postId, _currentUserId!);
  }

  @override
  Widget build(BuildContext context) {
    final bool canManage = _isAdmin || _currentUserId == widget.authorId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          categoryBadge(widget.category),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
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
          Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 8),
          Text(widget.description, style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.5)),
          if (widget.postImages != null && widget.postImages!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildPostImages(),
          ],
          const SizedBox(height: 16),
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: widget.author))),
      child: Container(
        width: 40, height: 40,
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
        child: ClipOval(child: widget.authorPhotoUrl != null && widget.authorPhotoUrl!.isNotEmpty ? Image.network(widget.authorPhotoUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey)) : const Icon(Icons.person, color: Colors.grey)),
      ),
    );
  }

  Widget _buildPostImages() {
    return Column(children: widget.postImages!.map((url) => Padding(padding: const EdgeInsets.only(bottom: 10.0), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(url, width: double.infinity, fit: BoxFit.cover)))).toList());
  }

  Widget _buildMenu(bool canManage) {
    return PopupMenuButton<String>(
      onSelected: (val) { 
        if (val == 'delete') {
          _handleDelete();
        } else if (val == 'edit') {
          Navigator.push(context, MaterialPageRoute(builder: (c) => EditPostPage(postId: widget.postId, initialTitle: widget.title, initialDescription: widget.description, initialCategory: widget.category)));
        } else if (val == 'save') {
          _toggleBookmark();
        }
      },
      itemBuilder: (context) => [
        if (canManage) const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (canManage) const PopupMenuItem(value: 'delete', child: Text('Delete')),
        PopupMenuItem(value: 'save', child: Text(_isBookmarked ? 'Unsave' : 'Save')),
      ],
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _buildPill(Icons.arrow_upward, '$_upvoteCount', _isUpvoted ? const Color(0xFFFB8C00) : Colors.grey, _toggleUpvote),
        const Spacer(),
        IconButton(icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: _isBookmarked ? const Color(0xFFFB8C00) : Colors.grey, size: 22), onPressed: _toggleBookmark),
      ],
    );
  }

  Widget _buildPill(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 8), Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold))]),
      ),
    );
  }

  void _handleDelete() async {
    final ok = await showDialog<bool>(
      context: context, 
      builder: (c) => AlertDialog(
        title: const Text('Delete Post?'), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')), 
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
        ],
      ),
    );
    if (ok == true) { 
      await _postService.deletePost(widget.postId); 
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
