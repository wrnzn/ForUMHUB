import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ForUMHUB/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketService {
  final CollectionReference _productCollection = FirebaseFirestore.instance.collection('products');
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() => _auth.currentUser;

  Stream<List<Product>> getProducts() {
    return _productCollection.orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) return getProducts();
    final lowerQuery = query.toLowerCase();
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).where((p) => p.title.toLowerCase().contains(lowerQuery) || p.details.toLowerCase().contains(lowerQuery)).toList();
    });
  }

  Stream<List<Product>> getProductsByUser(String userId) {
    return _productCollection.where('sellerId', isEqualTo: userId).orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // NEW: Get products bookmarked by user
  Stream<List<Product>> getBookmarkedProducts(String userId) {
    return _userCollection.doc(userId).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists) return [];
      final data = userDoc.data() as Map<String, dynamic>?;
      List<String> ids = List<String>.from(data?['bookmarked_products'] ?? []);
      if (ids.isEmpty) return [];
      final snapshots = await Future.wait(ids.map((id) => _productCollection.doc(id).get()));
      return snapshots.where((d) => d.exists).map((d) => Product.fromFirestore(d)).toList();
    });
  }

  Future<void> addProduct(String title, String price, String category, String details, String sellerId, String sellerName, {String? imageUrl, String? sellerPhotoUrl}) async {
    await _productCollection.add({
      'title': title, 'price': price, 'category': category, 'details': details, 'sellerId': sellerId,
      'sellerName': sellerName, 'imageUrl': imageUrl, 'sellerPhotoUrl': sellerPhotoUrl,
      'timestamp': Timestamp.now(), 'likes': 0, 'likedBy': [],
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _productCollection.doc(productId).delete();
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _productCollection.doc(productId).update(data);
  }

  // NEW: Save bookmark to Firestore
  Future<void> toggleProductBookmark(String productId, String userId) async {
    final userDoc = await _userCollection.doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    List bookmarks = List.from(userData?['bookmarked_products'] ?? []);
    if (bookmarks.contains(productId)) bookmarks.remove(productId);
    else bookmarks.add(productId);
    await _userCollection.doc(userId).set({'bookmarked_products': bookmarks}, SetOptions(merge: true));
  }

  // NEW: Check if product is bookmarked
  Future<bool> isProductBookmarked(String productId, String userId) async {
    final doc = await _userCollection.doc(userId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>?;
    return (List.from(data?['bookmarked_products'] ?? [])).contains(productId);
  }

  Future<void> toggleProductLike(String productId, String userId) async {
    final ref = _productCollection.doc(productId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final data = doc.data() as Map<String, dynamic>;
    List likedBy = data['likedBy'] ?? [];
    if (likedBy.contains(userId)) {
      await ref.update({'likes': FieldValue.increment(-1), 'likedBy': FieldValue.arrayRemove([userId])});
    } else {
      await ref.update({'likes': FieldValue.increment(1), 'likedBy': FieldValue.arrayUnion([userId])});
    }
  }

  Stream<List<Product>> getFeaturedProducts() {
    return _productCollection.orderBy('likes', descending: true).limit(5).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }
}
