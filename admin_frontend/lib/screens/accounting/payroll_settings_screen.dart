import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/payroll_providers.dart';
import '../../core/services/api_service.dart';

class PayrollSettingsScreen extends ConsumerStatefulWidget {
  final ApiService apiService;

  const PayrollSettingsScreen({super.key, required this.apiService});

  @override
  ConsumerState<PayrollSettingsScreen> createState() => _PayrollSettingsScreenState();
}

class _PayrollSettingsScreenState extends ConsumerState<PayrollSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _monthlyWorkDaysController;
  late TextEditingController _salaryPaymentDayController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _monthlyWorkDaysController = TextEditingController();
    _salaryPaymentDayController = TextEditingController();
  }

  @override
  void dispose() {
    _monthlyWorkDaysController.dispose();
    _salaryPaymentDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الرواتب'),
      ),
      body: ref.watch(payrollSettingsProvider).when(
        data: (settings) {
          _monthlyWorkDaysController.text = settings['monthly_work_days'].toString();
          _salaryPaymentDayController.text = settings['salary_payment_day'].toString();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إعدادات عامة',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _monthlyWorkDaysController,
                            decoration: const InputDecoration(
                              labelText: 'أيام العمل الشهرية الافتراضية',
                              hintText: 'مثال: 30',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال عدد أيام العمل';
                              }
                              final days = int.tryParse(value);
                              if (days == null || days < 1 || days > 31) {
                                return 'يرجى إدخال رقم صحيح بين 1 و 31';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _salaryPaymentDayController,
                            decoration: const InputDecoration(
                              labelText: 'يوم الدفع من كل شهر',
                              hintText: 'مثال: 28',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال يوم الدفع';
                              }
                              final day = int.tryParse(value);
                              if (day == null || day < 1 || day > 31) {
                                return 'يرجى إدخال رقم صحيح بين 1 و 31';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('حفظ الإعدادات'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('خطأ في تحميل الإعدادات: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.apiService.put('/payroll/settings', data: {
        'monthly_work_days': int.parse(_monthlyWorkDaysController.text),
        'salary_payment_day': int.parse(_salaryPaymentDayController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
        );
      }

      // Refresh settings
      ref.invalidate(payrollSettingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ الإعدادات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
