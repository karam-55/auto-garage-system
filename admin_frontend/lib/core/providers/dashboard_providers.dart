import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

final salesStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/sales-stats');
  return res.data;
});

final purchaseStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/purchase-stats');
  return res.data;
});

final inventoryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/inventory-stats');
  return res.data;
});

final manufacturingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/manufacturing-stats');
  return res.data;
});

final hrStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/hr-stats');
  return res.data;
});

final fixedAssetsStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/fixed-assets-stats');
  return res.data;
});
