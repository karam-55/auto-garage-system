import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/remote/inventory_remote_datasource.dart';
import '../datasources/local/cache_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource _remoteDataSource;
  final CacheDataSource _cacheDataSource;

  InventoryRepositoryImpl(this._remoteDataSource, this._cacheDataSource);

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      // Check cache first (1 hour expiry - inventory changes rarely)
      final isExpired = await _cacheDataSource.isExpired('inventory_items', const Duration(hours: 1));
      
      if (!isExpired) {
        final cachedData = await _cacheDataSource.getList('inventory_items');
        if (cachedData.isNotEmpty) {
          return cachedData.map((json) => InventoryItemModel.fromJson(json).toEntity()).toList();
        }
      }

      // Fetch from remote
      final itemModels = await _remoteDataSource.getInventoryItems();
      final items = itemModels.map((model) => model.toEntity()).toList();

      // Save to cache
      await _cacheDataSource.saveList('inventory_items', itemModels.map((m) => m.toJson()).toList());
      await _cacheDataSource.setTimestamp('inventory_items');

      return items;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get inventory items: $e');
    }
  }

  @override
  Future<bool> consumePart(String variantId, int quantity, String bookingId) async {
    try {
      final success = await _remoteDataSource.consumePart(variantId, quantity, bookingId);

      if (success) {
        // Clear inventory cache to force refresh
        await _cacheDataSource.remove('inventory_items');
      }

      return success;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to consume part: $e');
    }
  }
}
