import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

final bookingsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/sales-stats');
  return res;
});

final salesStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/sales-stats');
  return res;
});

final purchaseStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/purchase-stats');
  return res;
});

final inventoryStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/inventory-stats');
  return res;
});

final manufacturingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/manufacturing-stats');
  return res;
});

final hrStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/hr-stats');
  return res;
});

final fixedAssetsStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/dashboard/fixed-assets-stats');
  return res;
});
