import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/post_service.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/widgets/home_page/home_post_card_fixed.dart';
import 'package:ForUMHUB/widgets/home_page/home_ask_sell_section.dart';
import 'package:ForUMHUB/utils/course_constants.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CampusPage extends StatefulWidget {
  const CampusPage({super.key});

  @override
  State<CampusPage> createState() => _CampusPageState();
}

class _CampusPageState extends State<CampusPage> {
  final PostService _postService = PostService();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: _postService.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final posts = snapshot.data ?? [];
        final filtered = _selectedCategory == 'All' 
            ? posts 
            : posts.where((p) => p.category == _selectedCategory).toList();

        // Using a single ListView for everything to enable natural scrolling
        return AnimationLimiter(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 100),
            itemCount: filtered.length + 2, // +2 for the Header and the Category Chips
            itemBuilder: (context, index) {
              // 1. The "What do you want to ask or sell" section (at the top)
              if (index == 0) {
                return const HomeAskSellSection();
              }
              
              // 2. The Horizontal Category Chips
              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: CourseConstants.categories.length + 1,
                      itemBuilder: (context, cIndex) {
                        final category = cIndex == 0 ? 'All' : CourseConstants.categories[cIndex - 1];
                        final bool isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) => setState(() => _selectedCategory = category),
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFFFB8C00).withOpacity(0.15),
                            checkmarkColor: const Color(0xFFFB8C00),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFFFB8C00) : Colors.black54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(color: isSelected ? const Color(0xFFFB8C00) : Colors.grey.shade300),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              // 3. The actual post cards
              final post = filtered[index - 2];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HomePostCardFixed(
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
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
