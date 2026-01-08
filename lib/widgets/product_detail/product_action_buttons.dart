import 'package:flutter/material.dart';

class ProductActionButtons extends StatelessWidget {
  final VoidCallback onContactSeller;
  final VoidCallback onBookmark;

  const ProductActionButtons({
    super.key,
    required this.onContactSeller,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onContactSeller,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Contact Seller',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onBookmark,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.bookmark_border, color: Colors.grey),
        ),
      ],
    );
  }
}
