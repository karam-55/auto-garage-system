import '../../models/inventory_item_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/exceptions.dart';

class InventoryRemoteDataSource {
  final DioClient _dioClient;

  InventoryRemoteDataSource(this._dioClient);

  Future<List<InventoryItemModel>> getInventoryItems() async {
    try {
      final response = await _dioClient.get('/api/inventory/variants');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => InventoryItemModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get inventory items');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<bool> consumePart(String variantId, int quantity, String bookingId) async {
    try {
      final response = await _dioClient.post(
        '/api/inventory/consume',
        data: {
          'variantId': variantId,
          'quantity': quantity,
          'bookingId': bookingId,
        },
      );

      return response.statusCode == 200;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
