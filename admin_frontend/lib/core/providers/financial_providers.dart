import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

final fiscalPeriodsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/fiscal-periods');
  return response as List<dynamic>;
});

// Vendors
final vendorsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/vendors');
  return response as List<dynamic>;
});

final createVendorProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/vendors', data);
  return response;
});

final updateVendorProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final id = params['id'] as int;
  final data = params['data'] as Map<String, dynamic>;
  final response = await api.put('/api/vendors/$id', data);
  return response;
});

final deleteVendorProvider = FutureProvider.autoDispose.family<bool, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/api/vendors/$id');
  return true;
});

// Purchase Invoices
final purchaseInvoicesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/purchase-invoices');
  return response as List<dynamic>;
});

final createPurchaseInvoiceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/purchase-invoices', data);
  return response;
});

final payPurchaseInvoiceProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.put('/api/purchase-invoices/${data['id']}/pay', data);
  return response;
});

// Expenses
final expensesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/expenses');
  return response as List<dynamic>;
});

final createExpenseProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/expenses', data);
  return response;
});

final deleteExpenseProvider = FutureProvider.autoDispose.family<void, int>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  await api.delete('/api/expenses/$id');
});

// Bank Accounts
final bankAccountsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/bank-accounts');
  return response as List<dynamic>;
});

final createBankAccountProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/bank-accounts', data);
  return response;
});

final bankReconciliationProvider = FutureProvider.autoDispose.family<List<dynamic>, int>((ref, bankAccountId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/bank-accounts/$bankAccountId/reconciliation');
  return response as List<dynamic>;
});

final reconcileBankAccountProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final id = params['id'] as int;
  final data = params['data'] as Map<String, dynamic>;
  final response = await api.post('/bank-accounts/$id/reconcile', data);
  return response;
});
