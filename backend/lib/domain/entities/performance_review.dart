class PerformanceReview {
  final int? id;
  final String userId;
  final String reviewerId;
  final DateTime reviewDate;
  final double overallRating; // 1.0 to 5.0
  final String? strengths;
  final String? weaknesses;
  final String? goals;
  final String? comments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PerformanceReview({
    this.id,
    required this.userId,
    required this.reviewerId,
    required this.reviewDate,
    required this.overallRating,
    this.strengths,
    this.weaknesses,
    this.goals,
    this.comments,
    required this.createdAt,
    this.updatedAt,
  });

  PerformanceReview copyWith({
    int? id,
    String? userId,
    String? reviewerId,
    DateTime? reviewDate,
    double? overallRating,
    String? strengths,
    String? weaknesses,
    String? goals,
    String? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PerformanceReview(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewDate: reviewDate ?? this.reviewDate,
      overallRating: overallRating ?? this.overallRating,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      goals: goals ?? this.goals,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'reviewer_id': reviewerId,
      'review_date': reviewDate.toIso8601String(),
      'overall_rating': overallRating,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'goals': goals,
      'comments': comments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory PerformanceReview.fromJson(Map<String, dynamic> json) {
    return PerformanceReview(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewDate: DateTime.parse(json['review_date'] as String),
      overallRating: (json['overall_rating'] as num).toDouble(),
      strengths: json['strengths'] as String?,
      weaknesses: json['weaknesses'] as String?,
      goals: json['goals'] as String?,
      comments: json['comments'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}
