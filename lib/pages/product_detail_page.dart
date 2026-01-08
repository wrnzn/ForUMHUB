import 'package:flutter/material.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/widgets/product_detail/product_detail_card.dart';
import 'package:ForUMHUB/widgets/product_detail/product_action_buttons.dart';
import 'package:ForUMHUB/models/chat_model.dart';
import 'package:ForUMHUB/services/message_service.dart';
import 'package:ForUMHUB/services/market_service.dart';
import 'package:ForUMHUB/pages/conversation_page.dart';
import 'package:ForUMHUB/pages/edit_product_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final MessageService _messageService = MessageService();
  final MarketService _marketService = MarketService();
  bool _isBookmarked = false;

  Future<void> _handleContactSeller() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to contact seller')));
      return;
    }
    if (currentUserId == widget.product.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You cannot contact yourself')));
      return;
    }

    try {
      final chatId = await _messageService.getOrCreateChatId(widget.product.sellerId, otherUserName: widget.product.sellerName);
      final chatItem = ChatItemModel(id: chatId, name: widget.product.sellerName, lastMessage: 'Hi! I\'m interested in ${widget.product.title}', time: DateTime.now().toString(), unreadCount: 0);
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(chatPartner: chatItem)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(c, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Yes')),
        ],
      ),
    );
    if (ok == true) {
      await _marketService.deleteProduct(widget.product.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAuthor = currentUserId == widget.product.sellerId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(widget.product.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        actions: [
          if (isAuthor) 
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'delete') _handleDelete();
                if (val == 'edit') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditProductPage(product: widget.product)));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductDetailCard(product: widget.product),
            const SizedBox(height: 24),
            ProductActionButtons(
              onContactSeller: _handleContactSeller,
              onBookmark: () {
                setState(() => _isBookmarked = !_isBookmarked);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isBookmarked ? 'Product bookmarked' : 'Bookmark removed')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
