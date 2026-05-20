import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

final payrollSettingsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/payroll/settings');
  return response;
});

final salaryListProvider = FutureProvider.autoDispose.family<List<dynamic>, String?>((ref, monthYear) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/payroll/salaries${monthYear != null ? '?month_year=$monthYear' : ''}');
  return response as List<dynamic>;
});

final createSalaryPaymentProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/payroll/generate', data);
  return response;
});

final paySalaryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, Map<String, dynamic>>((ref, data) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.post('/api/payroll/salaries/${data['id']}/pay', data);
  return response;
});

final payrollReportProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, monthYear) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/api/payroll/report?month_year=$monthYear');
  return response;
});
