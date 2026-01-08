class ReviewModel {
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
