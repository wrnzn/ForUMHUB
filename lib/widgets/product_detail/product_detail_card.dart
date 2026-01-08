import 'package:flutter/material.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:ForUMHUB/pages/profile_page.dart';

class ProductDetailCard extends StatelessWidget {
  final Product product;

  const ProductDetailCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 64, color: Colors.grey))
                : const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 16),
        Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("₱${product.price}", style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildCategoryLabel(context),
        const SizedBox(height: 24),
        const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(product.details, style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5)),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildSellerSection(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryLabel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(product.category, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSellerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seller Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: product.sellerName))),
          child: Row(
            children: [
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                child: ClipOval(
                  child: product.sellerPhotoUrl != null && product.sellerPhotoUrl!.isNotEmpty
                      ? Image.network(
                          product.sellerPhotoUrl!, 
                          fit: BoxFit.cover,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) return child;
                            return AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, child: child);
                          },
                          errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey),
                        )
                      : const Icon(Icons.person, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Text('Verified Student', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
