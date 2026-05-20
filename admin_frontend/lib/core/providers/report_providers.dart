import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import 'erp_providers.dart';

final trialBalanceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/trial-balance');
  return response;
});

final profitLossProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/reports/profit-loss');
  return response;
});

final balanceSheetProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/reports/balance-sheet');
  return response;
});

final generalLedgerProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/reports/general-ledger');
  return response;
});

// Advanced Reports Providers
final cashFlowProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final fromDate = params['from'] as DateTime;
  final toDate = params['to'] as DateTime;
  final response = await api.get('/api/reports/cash-flow?from=${fromDate.toIso8601String().split('T')[0]}&to=${toDate.toIso8601String().split('T')[0]}');
  return response;
});

final breakEvenProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final fromDate = params['from'] as DateTime;
  final toDate = params['to'] as DateTime;
  final response = await api.get('/api/reports/break-even?from=${fromDate.toIso8601String().split('T')[0]}&to=${toDate.toIso8601String().split('T')[0]}');
  return response;
});

final tradingAccountProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final fromDate = params['from'] as DateTime;
  final toDate = params['to'] as DateTime;
  final response = await api.get('/api/reports/trading?from=${fromDate.toIso8601String().split('T')[0]}&to=${toDate.toIso8601String().split('T')[0]}');
  return response;
});
