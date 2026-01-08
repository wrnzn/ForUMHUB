import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/search_service.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/widgets/home_page/home_post_card_fixed.dart';
import 'package:ForUMHUB/widgets/market_page/market_product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() { _searchQuery = query.trim(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: TextField(controller: _searchController, autofocus: true, decoration: InputDecoration(hintText: 'Search posts, products...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey[400])), onSubmitted: _performSearch),
        actions: [IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () => _performSearch(_searchController.text))],
        bottom: TabBar(controller: _tabController, labelColor: Theme.of(context).colorScheme.primary, unselectedLabelColor: Colors.grey, indicatorColor: Theme.of(context).colorScheme.primary, tabs: const [Tab(text: 'Posts'), Tab(text: 'Products')]),
      ),
      body: _searchQuery.isEmpty ? _buildEmptyState() : TabBarView(controller: _tabController, children: [_buildPostsResults(), _buildProductsResults()]),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search, size: 64, color: Colors.grey[300]), const SizedBox(height: 16), Text('Search for posts and products', style: TextStyle(color: Colors.grey[600], fontSize: 16))]));
  }

  Widget _buildPostsResults() {
    return StreamBuilder<List<Post>>(
      stream: _searchService.searchPosts(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final posts = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            Post post = posts[index];
            return HomePostCardFixed(
              postId: post.id, title: post.title, author: post.authorName, authorId: post.authorId,
              authorPhotoUrl: post.authorPhotoUrl, course: post.course ?? 'General',
              category: post.category, // FIXED: Added required category
              timestamp: post.formattedTimestamp, description: post.description,
              upvotes: post.upvotes, bookmarks: post.bookmarks, commentCount: post.commentCount,
              postImages: post.avatarUrls,
            );
          },
        );
      },
    );
  }

  Widget _buildProductsResults() {
    return StreamBuilder<List<Product>>(
      stream: _searchService.searchProducts(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) => MarketProductCard(product: products[index], onLike: () {}),
        );
      },
    );
  }
}
