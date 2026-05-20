import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

// Dashboard Stats
final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/stats');
  return res as Map<String, dynamic>;
});

final revenueStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/revenue');
  return res as Map<String, dynamic>;
});

// ERP Dashboard Stats
final salesStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/sales-stats');
  return res as Map<String, dynamic>;
});

final purchaseStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/purchase-stats');
  return res as Map<String, dynamic>;
});

final inventoryStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/inventory-stats');
  return res as Map<String, dynamic>;
});

final manufacturingStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/manufacturing-stats');
  return res as Map<String, dynamic>;
});

final hrStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/hr-stats');
  return res as Map<String, dynamic>;
});

final fixedAssetsStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/api/dashboard/fixed-assets-stats');
  return res as Map<String, dynamic>;
});
