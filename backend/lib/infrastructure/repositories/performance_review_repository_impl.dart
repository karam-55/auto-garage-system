import 'package:postgres/postgres.dart';
import '../../domain/entities/performance_review.dart';
import '../../domain/repositories/performance_review_repository.dart';
import '../database/database_connection.dart';

class PerformanceReviewRepositoryImpl implements PerformanceReviewRepository {
  final DatabaseConnection _db;

  PerformanceReviewRepositoryImpl(this._db);

  @override
  Future<PerformanceReview> create(PerformanceReview review) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''INSERT INTO performance_reviews (user_id, reviewer_id, review_date, overall_rating, strengths, weaknesses, goals, comments, created_at)
           VALUES (@userId, @reviewerId, @reviewDate, @overallRating, @strengths, @weaknesses, @goals, @comments, @createdAt)
           RETURNING id, created_at'''),
        parameters: {
          'userId': review.userId,
          'reviewerId': review.reviewerId,
          'reviewDate': review.reviewDate,
          'overallRating': review.overallRating,
          'strengths': review.strengths,
          'weaknesses': review.weaknesses,
          'goals': review.goals,
          'comments': review.comments,
          'createdAt': review.createdAt,
        },
      );
      final row = result.first;
      return review.copyWith(
        id: row[0] as int,
        createdAt: row[1] as DateTime,
      );
    });
  }

  @override
  Future<PerformanceReview?> findById(int id) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, user_id, reviewer_id, review_date, overall_rating, strengths, weaknesses, goals, comments, created_at, updated_at
           FROM performance_reviews WHERE id = @id'''),
        parameters: {'id': id},
      );
      if (result.isEmpty) return null;
      return _mapRowToReview(result.first);
    });
  }

  @override
  Future<List<PerformanceReview>> findByUserId(String userId) async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        Sql.named('''SELECT id, user_id, reviewer_id, review_date, overall_rating, strengths, weaknesses, goals, comments, created_at, updated_at
           FROM performance_reviews WHERE user_id = @userId ORDER BY review_date DESC'''),
        parameters: {'userId': userId},
      );
      return result.map(_mapRowToReview).toList();
    });
  }

  @override
  Future<List<PerformanceReview>> findAll() async {
    return await _db.runInTransaction((session) async {
      final result = await session.execute(
        '''SELECT id, user_id, reviewer_id, review_date, overall_rating, strengths, weaknesses, goals, comments, created_at, updated_at
           FROM performance_reviews ORDER BY review_date DESC''',
      );
      return result.map(_mapRowToReview).toList();
    });
  }

  @override
  Future<PerformanceReview> update(PerformanceReview review) async {
    return await _db.runInTransaction((session) async {
      await session.execute(
        Sql.named('''UPDATE performance_reviews SET
           user_id = @userId,
           reviewer_id = @reviewerId,
           review_date = @reviewDate,
           overall_rating = @overallRating,
           strengths = @strengths,
           weaknesses = @weaknesses,
           goals = @goals,
           comments = @comments,
           updated_at = NOW()
           WHERE id = @id'''),
        parameters: {
          'id': review.id,
          'userId': review.userId,
          'reviewerId': review.reviewerId,
          'reviewDate': review.reviewDate,
          'overallRating': review.overallRating,
          'strengths': review.strengths,
          'weaknesses': review.weaknesses,
          'goals': review.goals,
          'comments': review.comments,
        },
      );
      return review.copyWith(updatedAt: DateTime.now());
    });
  }

  @override
  Future<void> delete(int id) async {
    return await _db.runInTransaction((session) async {
      await session.execute(Sql.named('DELETE FROM performance_reviews WHERE id = @id'), parameters: {'id': id});
    });
  }

  PerformanceReview _mapRowToReview(List<dynamic> row) {
    return PerformanceReview(
      id: row[0] as int,
      userId: row[1] as String,
      reviewerId: row[2] as String,
      reviewDate: row[3] as DateTime,
      overallRating: (row[4] as num).toDouble(),
      strengths: row[5] as String?,
      weaknesses: row[6] as String?,
      goals: row[7] as String?,
      comments: row[8] as String?,
      createdAt: row[9] as DateTime,
      updatedAt: row[10] as DateTime?,
    );
  }
}
