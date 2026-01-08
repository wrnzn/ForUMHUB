import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String price;
  final String category;
  final String details;
  final String sellerId;
  final String sellerName;
  final String? sellerPhotoUrl; // Added sellerPhotoUrl
  final String? imageUrl;
  final bool isFeatured;
  final int likes;
  final String icon;
  final Timestamp timestamp;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.details,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhotoUrl, // Added sellerPhotoUrl
    this.imageUrl,
    this.isFeatured = false,
    this.likes = 0,
    this.icon = 'laptop',
    required this.timestamp,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      price: data['price'] ?? '',
      category: data['category'] ?? '',
      details: data['details'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhotoUrl: data['sellerPhotoUrl'], // Added sellerPhotoUrl
      imageUrl: data['imageUrl'],
      isFeatured: data['isFeatured'] ?? false,
      likes: data['likes'] ?? 0,
      icon: data['icon'] ?? 'laptop',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  static IconData fromString(String icon) {
    switch (icon) {
      case 'laptop': return Icons.laptop;
      case 'coffee': return Icons.coffee;
      case 'lightbulb': return Icons.lightbulb;
      default: return Icons.shopping_bag;
    }
  }
}
