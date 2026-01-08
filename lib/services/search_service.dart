import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ForUMHUB/models/post_model.dart';
import 'package:ForUMHUB/models/product_model.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // KEYWORD SEARCH: Finds words anywhere in the title
  Stream<List<Post>> searchPosts(String query) {
    if (query.isEmpty) {
      return _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
    }

    final lowerQuery = query.toLowerCase();

    return _firestore
        .collection('posts')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Post.fromFirestore(doc))
              .where((post) {
                final title = post.title.toLowerCase();
                final description = post.description.toLowerCase();
                // Match keywords in title OR description
                return title.contains(lowerQuery) || description.contains(lowerQuery);
              }).toList();
        });
  }

  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) {
      return _firestore.collection('products').orderBy('timestamp', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
    }

    final lowerQuery = query.toLowerCase();

    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .where((product) {
                final title = product.title.toLowerCase();
                final details = product.details.toLowerCase();
                return title.contains(lowerQuery) || details.contains(lowerQuery);
              }).toList();
        });
  }
}
