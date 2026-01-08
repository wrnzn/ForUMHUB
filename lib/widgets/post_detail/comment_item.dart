import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentItem extends StatefulWidget {
  final String authorName;
  final String authorId;
  final String commentId;
  final String postId;
  final String timeAgo;
  final String text;
  final int upvotes;
  final String? commentImageUrl;
  final VoidCallback? onReply;

  const CommentItem({
    super.key,
    required this.authorName,
    required this.authorId,
    required this.commentId,
    required this.postId,
    required this.timeAgo,
    required this.text,
    required this.upvotes,
    this.commentImageUrl,
    this.onReply,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  bool _isUpvoted = false;
  bool _isAdmin = false;
  late int _upvoteCount;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _upvoteCount = widget.upvotes;
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (_currentUserId != null) {
      final isUpvoted = await _postService.isCommentUpvoted(widget.commentId, _currentUserId!);
      final isAdmin = await _userService.isAdmin(_currentUserId!);
      if (mounted) {
        setState(() {
          _isUpvoted = isUpvoted;
          _isAdmin = isAdmin;
        });
      }
    }
  }

  Future<void> _toggleUpvote() async {
    if (_currentUserId == null) return;
    setState(() { _isUpvoted ? _upvoteCount-- : _upvoteCount++; _isUpvoted = !_isUpvoted; });
    await _postService.toggleCommentUpvote(widget.commentId, _currentUserId!);
  }

  @override
  Widget build(BuildContext context) {
    final bool canManage = _isAdmin || _currentUserId == widget.authorId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Click Logic
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: widget.authorName))),
            child: _buildAvatar(_userService),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: widget.authorName))),
                  child: Row(
                    children: [
                      Flexible(child: Text(widget.authorName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      const SizedBox(width: 8),
                      Text(widget.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                if (widget.text.isNotEmpty) Text(widget.text, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                if (widget.commentImageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(widget.commentImageUrl!, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
                  ),
                ],
                const SizedBox(height: 6),
                _buildCommentActions(),
              ],
            ),
          ),
          _buildMenu(canManage),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserService service) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: service.getUserDataStream(widget.authorId),
      builder: (context, snapshot) {
        final photo = snapshot.data?['photoUrl'];
        return Container(width: 32, height: 32, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF5F5F5)), child: ClipOval(child: photo != null ? Image.network(photo, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person, size: 18, color: Colors.grey)) : const Icon(Icons.person, size: 18, color: Colors.grey)));
      },
    );
  }

  Widget _buildCommentActions() {
    return Row(
      children: [
        GestureDetector(onTap: _toggleUpvote, child: Row(children: [Icon(Icons.arrow_upward, color: _isUpvoted ? Theme.of(context).colorScheme.primary : Colors.grey, size: 14), const SizedBox(width: 4), Text('$_upvoteCount', style: TextStyle(color: _isUpvoted ? Theme.of(context).colorScheme.primary : Colors.grey, fontSize: 11))])),
        const SizedBox(width: 16),
        GestureDetector(onTap: widget.onReply, child: const Text('Reply', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildMenu(bool canManage) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        if (val == 'delete') {
          _postService.deleteComment(widget.commentId, widget.postId);
        }
      },
      itemBuilder: (context) => [
        if (canManage) const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
    );
  }
}
