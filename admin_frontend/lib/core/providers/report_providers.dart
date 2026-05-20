import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import 'api_provider.dart';

final trialBalanceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['from'] != null) {
    queryParams['from'] = (params['from'] as DateTime).toIso8601String().split('T')[0];
  }
  if (params['to'] != null) {
    queryParams['to'] = (params['to'] as DateTime).toIso8601String().split('T')[0];
  }
  if (params['fiscalPeriodId'] != null) {
    queryParams['fiscalPeriodId'] = params['fiscalPeriodId'].toString();
  }
  final queryString = queryParams.isNotEmpty ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}' : '';
  final response = await api.get('/api/trial-balance$queryString');
  return response;
});

final profitLossProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['from'] != null) {
    queryParams['from'] = (params['from'] as DateTime).toIso8601String().split('T')[0];
  }
  if (params['to'] != null) {
    queryParams['to'] = (params['to'] as DateTime).toIso8601String().split('T')[0];
  }
  if (params['fiscalPeriodId'] != null) {
    queryParams['fiscalPeriodId'] = params['fiscalPeriodId'].toString();
  }
  final queryString = queryParams.isNotEmpty ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}' : '';
  final response = await api.get('/api/reports/profit-loss$queryString');
  return response;
});

final balanceSheetProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['asOfDate'] != null) {
    queryParams['asOfDate'] = (params['asOfDate'] as DateTime).toIso8601String().split('T')[0];
  }
  if (params['fiscalPeriodId'] != null) {
    queryParams['fiscalPeriodId'] = params['fiscalPeriodId'].toString();
  }
  final queryString = queryParams.isNotEmpty ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}' : '';
  final response = await api.get('/api/reports/balance-sheet$queryString');
  return response;
});

final generalLedgerProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['from'] != null) {
    queryParams['from'] = (params['from'] as DateTime).toIso8601String().split('T')[0];
  }
  if (params['to'] != null) {
    queryParams['to'] = (params['to'] as DateTime).toIso8601String().split('T')[0];
  }
  if (params['accountId'] != null) {
    queryParams['accountId'] = params['accountId'].toString();
  }
  if (params['fiscalPeriodId'] != null) {
    queryParams['fiscalPeriodId'] = params['fiscalPeriodId'].toString();
  }
  final queryString = queryParams.isNotEmpty ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}' : '';
  final response = await api.get('/api/reports/general-ledger$queryString');
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
