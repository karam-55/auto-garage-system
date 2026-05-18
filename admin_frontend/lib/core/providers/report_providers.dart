import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/account.dart';

final trialBalanceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['from'] != null) queryParams['from'] = params['from']!;
  if (params['to'] != null) queryParams['to'] = params['to']!;
  if (params['fiscalPeriodId'] != null) queryParams['fiscalPeriodId'] = params['fiscalPeriodId']!;
  
  final response = await api.get('/api/trial-balance', queryParams: queryParams);
  return response;
});

final profitLossProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['from'] != null) queryParams['from'] = params['from']!;
  if (params['to'] != null) queryParams['to'] = params['to']!;
  if (params['fiscalPeriodId'] != null) queryParams['fiscalPeriodId'] = params['fiscalPeriodId']!;
  
  final response = await api.get('/api/reports/profit-loss', queryParams: queryParams);
  return response;
});

final balanceSheetProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['asOfDate'] != null) queryParams['asOfDate'] = params['asOfDate']!;
  if (params['fiscalPeriodId'] != null) queryParams['fiscalPeriodId'] = params['fiscalPeriodId']!;
  
  final response = await api.get('/api/reports/balance-sheet', queryParams: queryParams);
  return response;
});

final generalLedgerProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, String?>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (params['from'] != null) queryParams['from'] = params['from']!;
  if (params['to'] != null) queryParams['to'] = params['to']!;
  if (params['accountId'] != null) queryParams['accountId'] = params['accountId']!;
  if (params['fiscalPeriodId'] != null) queryParams['fiscalPeriodId'] = params['fiscalPeriodId']!;
  
  final response = await api.get('/api/reports/general-ledger', queryParams: queryParams);
  return response;
});

// Advanced Reports Providers
final cashFlowProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/reports/cash-flow', queryParams: {
    'from': params['from']!.toIso8601String(),
    'to': params['to']!.toIso8601String(),
  });
  return response;
});

final breakEvenProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/reports/break-even', queryParams: {
    'from': params['from']!.toIso8601String(),
    'to': params['to']!.toIso8601String(),
  });
  return response;
});

final tradingAccountProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/reports/trading', queryParams: {
    'from': params['from']!.toIso8601String(),
    'to': params['to']!.toIso8601String(),
  });
  return response;
});
