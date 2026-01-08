import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ForUMHUB/models/review_model.dart';

class ReviewService {
  final CollectionReference _reviewCollection = FirebaseFirestore.instance.collection('reviews');

  // Get reviews stream
  Stream<List<ReviewModel>> getReviews() {
    return _reviewCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ReviewModel(
          reviewerName: data['reviewerName'] ?? 'Anonymous',
          rating: (data['rating'] ?? 0.0).toDouble(),
          comment: data['comment'] ?? '',
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  // Add a review
  Future<void> addReview(String reviewerName, double rating, String comment) async {
    await _reviewCollection.add({
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.now(),
    });
  }

  // Calculate average rating
  Future<double> getAverageRating() async {
    final snapshot = await _reviewCollection.get();
    if (snapshot.docs.isEmpty) return 0.0;
    
    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['rating'] ?? 0.0).toDouble();
    }
    return total / snapshot.docs.length;
  }

  // Get review count
  Stream<int> getReviewCount() {
    return _reviewCollection.snapshots().map((snapshot) => snapshot.docs.length);
  }
}
