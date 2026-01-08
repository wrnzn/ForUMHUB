import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/home_page/home_post_card_fixed.dart';
import 'package:ForUMHUB/widgets/market_page/market_product_card.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/services/search_service.dart';

class SearchResultsPage extends StatefulWidget {
  final String initialQuery;
  const SearchResultsPage({super.key, required this.initialQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.text = widget.initialQuery;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search forUMhub...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (query) {
              setState(() {});
            },
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFB8C00),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFB8C00),
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Market'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsResults(),
          _buildMarketResults(),
        ],
      ),
    );
  }

  Widget _buildPostsResults() {
    return StreamBuilder<List<Post>>(
      stream: _searchService.searchPosts(_searchController.text),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            Post post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
            );
          },
        );
      },
    );
  }

  Widget _buildMarketResults() {
    return StreamBuilder<List<Product>>(
      stream: _searchService.searchProducts(_searchController.text),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            Product product = products[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MarketProductCard(
                product: product,
                onLike: () {},
              ),
            );
          },
        );
      },
    );
  }
}
