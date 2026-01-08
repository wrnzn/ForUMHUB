import 'package:flutter/material.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/pages/product_detail_page.dart';
import 'package:ForUMHUB/services/market_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onLike;

  const MarketProductCard({
    super.key,
    required this.product,
    this.onLike,
  });

  @override
  State<MarketProductCard> createState() => _MarketProductCardState();
}

class _MarketProductCardState extends State<MarketProductCard> {
  final MarketService _marketService = MarketService();
  final UserService _userService = UserService();
  bool _isBookmarked = false;
  bool _isAdmin = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (_userId != null) {
      final bookmarkStatus = await _marketService.isProductBookmarked(widget.product.id, _userId!);
      final adminStatus = await _userService.isAdmin(_userId!);
      if (mounted) {
        setState(() {
          _isBookmarked = bookmarkStatus;
          _isAdmin = adminStatus;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_userId == null) return;
    await _marketService.toggleProductBookmark(widget.product.id, _userId!);
    setState(() => _isBookmarked = !_isBookmarked);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isBookmarked ? 'Saved to bookmarks' : 'Removed from bookmarks'), duration: const Duration(seconds: 1)),
      );
    }
  }

  Future<void> _handleDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (ok == true) {
      await _marketService.deleteProduct(widget.product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);
    final bool canManage = _isAdmin || _userId == widget.product.sellerId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: widget.product)));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
                      ? Image.network(widget.product.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag_outlined, color: Colors.grey))
                      : Icon(Icons.shopping_bag_outlined, color: Colors.grey[300], size: 40),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text("₱${widget.product.price}", style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: Text(widget.product.category, style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text("• ${widget.product.details}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                      ],
                    ),
                  ],
                ),
              ),
              if (canManage)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  onPressed: _handleDelete,
                )
              else
                IconButton(
                  icon: Icon(_isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _isBookmarked ? brandOrange : Colors.grey[400], size: 24),
                  onPressed: _toggleBookmark,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
