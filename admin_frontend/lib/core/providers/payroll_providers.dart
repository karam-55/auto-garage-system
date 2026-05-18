import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final payrollSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/payroll/settings');
  return response;
});

final salaryListProvider = FutureProvider.autoDispose.family<List<dynamic>, String?>((ref, monthYear) async {
  final api = ref.read(apiServiceProvider);
  final queryParams = <String, String>{};
  if (monthYear != null) {
    queryParams['month_year'] = monthYear;
  }
  final response = await api.get('/payroll/salaries', queryParams: queryParams);
  return response as List<dynamic>;
});

final generatePayrollProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/payroll/generate', data: params);
  return response;
});

final paySalaryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, int>((ref, salaryPaymentId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/payroll/salaries/$salaryPaymentId/pay', data: {
    'payment_date': DateTime.now().toIso8601String(),
    'paid_by_user_id': 'current_user_id', // TODO: Get from auth
  });
  return response;
});

final payrollReportProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, monthYear) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/payroll/report', queryParams: {'month_year': monthYear});
  return response;
});
