import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'erp_providers.dart' show apiServiceProvider;

// Vendors
final vendorsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/vendors');
  return response as List<dynamic>;
});

final createVendorProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/vendors', data);
  return response;
});

final updateVendorProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final id = params['id'] as int;
  final data = params['data'] as Map<String, dynamic>;
  final response = await api.put('/vendors/$id', data);
  return response;
});

final deleteVendorProvider = FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/vendors/$id');
});

// Purchase Invoices
final purchaseInvoicesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/purchase-invoices');
  return response as List<dynamic>;
});

final createPurchaseInvoiceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/purchase-invoices', data);
  return response;
});

final payPurchaseInvoiceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final id = params['id'] as int;
  final data = params['data'] as Map<String, dynamic>;
  final response = await api.put('/purchase-invoices/$id/pay', data);
  return response;
});

// Expenses
final expensesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/expenses');
  return response as List<dynamic>;
});

final createExpenseProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/expenses', data);
  return response;
});

final deleteExpenseProvider = FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/expenses/$id');
});

// Bank Accounts
final bankAccountsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/bank-accounts');
  return response as List<dynamic>;
});

final createBankAccountProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/bank-accounts', data);
  return response;
});

final bankReconciliationProvider = FutureProvider.autoDispose.family<List<dynamic>, int>((ref, bankAccountId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/bank-accounts/$bankAccountId/reconciliation');
  return response as List<dynamic>;
});

final reconcileBankAccountProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final id = params['id'] as int;
  final data = params['data'] as Map<String, dynamic>;
  final response = await api.post('/bank-accounts/$id/reconcile', data);
  return response;
});
