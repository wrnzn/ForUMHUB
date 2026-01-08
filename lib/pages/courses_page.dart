import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/widgets/home_page/home_post_card_fixed.dart';
import 'package:ForUMHUB/widgets/course_utils.dart';
import 'package:ForUMHUB/utils/course_constants.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final PostService _postService = PostService();
  String? _selectedCourse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          elevation: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCourse,
                hint: const Text('Filter by Course', style: TextStyle(fontSize: 14)),
                isExpanded: true,
                menuMaxHeight: 400,
                // FIXED: Wrapped items to prevent overlap
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Courses')),
                  ...CourseConstants.allCourses.map((c) => DropdownMenuItem(
                    value: c, 
                    child: Text(
                      formatCourseName(c), // Use the same clean names as post cards
                      overflow: TextOverflow.ellipsis,
                    ),
                  )).toList(),
                ],
                onChanged: (v) => setState(() => _selectedCourse = v),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<List<Post>>(
            stream: _postService.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final posts = snapshot.data ?? [];
              final filtered = _selectedCourse == null ? posts : posts.where((p) => p.course == _selectedCourse).toList();
              
              if (filtered.isEmpty) return const Center(child: Text('No posts found for this course.', style: TextStyle(color: Colors.grey)));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final post = filtered[index];
                  return HomePostCardFixed(
                    postId: post.id,
                    title: post.title,
                    author: post.authorName,
                    authorId: post.authorId,
                    authorPhotoUrl: post.authorPhotoUrl,
                    course: post.course ?? 'General',
                    category: post.category,
                    timestamp: post.formattedTimestamp,
                    description: post.description,
                    upvotes: post.upvotes,
                    bookmarks: post.bookmarks,
                    commentCount: post.commentCount,
                    postImages: post.avatarUrls,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
