import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/market_page/market_search_bar.dart';
import 'package:ForUMHUB/widgets/market_page/market_filters.dart';
import 'package:ForUMHUB/widgets/market_page/market_product_card.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/services/market_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final MarketService _marketService = MarketService();
  String _searchQuery = '';
  String selectedCategory = 'All';
  String selectedSort = 'Latest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // FIXED: Using the new stateful MarketSearchBar
            MarketSearchBar(onSearch: (query) => setState(() => _searchQuery = query)),
            const SizedBox(height: 16),
            MarketFilters(
              selectedCategory: selectedCategory,
              selectedSort: selectedSort,
              onCategoryChanged: (cat) => setState(() => selectedCategory = cat),
              onSortChanged: (sort) => setState(() => selectedSort = sort),
            ),
            const SizedBox(height: 24),
            const Text("Today's Picks", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            _buildProductGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<List<Product>>(
      stream: _searchQuery.isEmpty ? _marketService.getProducts() : _marketService.searchProducts(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        List<Product> products = snapshot.data ?? [];
        if (selectedCategory != 'All') {
          products = products.where((p) => p.category == selectedCategory).toList();
        }

        if (selectedSort == 'Highest Price') {
          products.sort((a, b) => _parsePrice(b.price).compareTo(_parsePrice(a.price)));
        } else if (selectedSort == 'Lowest Price') {
          products.sort((a, b) => _parsePrice(a.price).compareTo(_parsePrice(b.price)));
        } else {
          products.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        }

        if (products.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('No items found.', style: TextStyle(color: Colors.grey))));

        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MarketProductCard(product: product, onLike: () => _marketService.toggleProductLike(product.id, _marketService.getCurrentUser()?.uid ?? '')),
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

  double _parsePrice(String price) {
    try {
      final cleanPrice = price.replaceAll('₱', '').replaceAll(',', '').trim();
      return double.parse(cleanPrice);
    } catch (e) {
      return 0.0;
    }
  }
}
