import 'package:flutter/material.dart';

class MarketFeaturedCard extends StatelessWidget {
  final String title;
  final String price;
  final IconData icon;
  final Color? color;

  const MarketFeaturedCard({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
