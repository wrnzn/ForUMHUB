import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/widgets/home_page/home_post_card_fixed.dart';

class MainFeedPage extends StatefulWidget {
  const MainFeedPage({super.key});

  @override
  State<MainFeedPage> createState() => _MainFeedPageState();
}

class _MainFeedPageState extends State<MainFeedPage> {
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<List<Post>>(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading posts'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) return const Center(child: Text('No posts yet'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: HomePostCardFixed(
                  postId: post.id,
                  title: post.title,
                  author: post.authorName,
                  authorId: post.authorId,
                  authorPhotoUrl: post.authorPhotoUrl,
                  course: post.course ?? 'General', // Correctly passing the user's course
                  category: post.category, // Correctly passing the post's category
                  timestamp: post.formattedTimestamp,
                  description: post.description,
                  upvotes: post.upvotes,
                  bookmarks: post.bookmarks,
                  commentCount: post.commentCount,
                  postImages: post.avatarUrls,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
