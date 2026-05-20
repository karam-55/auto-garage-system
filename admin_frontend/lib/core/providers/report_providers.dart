import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/account.dart';
import 'api_provider.dart';

final trialBalanceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  try {
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
  } catch (e) {
    print('Trial balance provider error: $e');
    // في حالة الخطأ، نعيد مصفوفة فارغة (لا نعلق)
    return {'lines': []};
  }
});

final profitLossProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  try {
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
  } catch (e) {
    print('Profit & loss provider error: $e');
    // في حالة الخطأ، نعيد مصفوفة فارغة (لا نعلق)
    return {'revenues': [], 'expenses': [], 'totalRevenue': 0, 'totalExpense': 0, 'netProfit': 0};
  }
});

final balanceSheetProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  try {
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
  } catch (e) {
    print('Balance sheet provider error: $e');
    // في حالة الخطأ، نعيد مصفوفة فارغة (لا نعلق)
    return {'assets': [], 'liabilities': [], 'totalAssets': 0, 'totalLiabilities': 0, 'equity': 0};
  }
});

final generalLedgerProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  try {
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
  } catch (e) {
    print('General ledger provider error: $e');
    // في حالة الخطأ، نعيد مصفوفة فارغة (لا نعلق)
    return {'entries': []};
  }
});

// Advanced Reports Providers
final cashFlowProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  try {
    final api = ref.read(apiServiceProvider);
    final fromDate = params['from'] as DateTime;
    final toDate = params['to'] as DateTime;
    final response = await api.get('/api/reports/cash-flow?from=${fromDate.toIso8601String().split('T')[0]}&to=${toDate.toIso8601String().split('T')[0]}');
    return response;
  } catch (e) {
    print('Cash flow provider error: $e');
    // في حالة الخطأ، نعيد مصفوفة فارغة (لا نعلق)
    return <String, dynamic>{};
  }
});

final breakEvenProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  try {
    final api = ref.read(apiServiceProvider);
    final fromDate = params['from'] as DateTime;
    final toDate = params['to'] as DateTime;
    final response = await api.get('/api/reports/break-even?from=${fromDate.toIso8601String().split('T')[0]}&to=${toDate.toIso8601String().split('T')[0]}');
    return response;
  } catch (e) {
    print('Break-even provider error: $e');
    // في حالة الخطأ، نعيد مصفوفة فارغة (لا نعلق)
    return <String, dynamic>{};
  }
});

final tradingAccountProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, DateTime>>((ref, params) async {
  try {
    final api = ref.read(apiServiceProvider);
    final fromDate = params['from'] as DateTime;
    final toDate = params['to'] as DateTime;
    final response = await api.get('/api/reports/trading?from=${fromDate.toIso8601String().split('T')[0]}&to=${toDate.toIso8601String().split('T')[0]}');
    return response;
  } catch (e) {
    print('Trading account provider error: $e');
    // في حالة الخطأ، نعيد مصفوفة فارغة (لا نعلق)
    return <String, dynamic>{};
  }
});
