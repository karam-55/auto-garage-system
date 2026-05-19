class PerformanceReview {
  final int id;
  final String userId;
  final String reviewerId;
  final String reviewPeriod;
  final double rating;
  final String? strengths;
  final String? areasForImprovement;
  final String? goals;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PerformanceReview({
    required this.id,
    required this.userId,
    required this.reviewerId,
    required this.reviewPeriod,
    required this.rating,
    this.strengths,
    this.areasForImprovement,
    this.goals,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PerformanceReview.fromJson(Map<String, dynamic> json) {
    return PerformanceReview(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewPeriod: json['review_period'] as String,
      rating: (json['rating'] as num).toDouble(),
      strengths: json['strengths'] as String?,
      areasForImprovement: json['areas_for_improvement'] as String?,
      goals: json['goals'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reviewer_id': reviewerId,
      'review_period': reviewPeriod,
      'rating': rating,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
      'goals': goals,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
