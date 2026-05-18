import '../entities/fixed_asset.dart';

abstract class FixedAssetRepository {
  Future<FixedAsset> create(FixedAsset asset);
  Future<FixedAsset?> findById(int id);
  Future<List<FixedAsset>> findAll();
  Future<List<FixedAsset>> findByCategory(String category);
  Future<List<FixedAsset>> findByStatus(String status);
  Future<FixedAsset> update(FixedAsset asset);
  Future<void> delete(int id);
}
