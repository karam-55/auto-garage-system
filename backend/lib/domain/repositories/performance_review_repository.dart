import '../entities/performance_review.dart';

abstract class PerformanceReviewRepository {
  Future<PerformanceReview> create(PerformanceReview review);
  Future<PerformanceReview?> findById(int id);
  Future<List<PerformanceReview>> findByUserId(String userId);
  Future<List<PerformanceReview>> findAll();
  Future<PerformanceReview> update(PerformanceReview review);
  Future<void> delete(int id);
}
