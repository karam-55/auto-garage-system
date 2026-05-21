import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../core/services/api_service.dart';
import '../core/services/accounting_settings_service.dart';
import '../core/models/accounting_settings.dart';
import '../core/constants/api_constants.dart';

class CompanySettingsScreen extends StatefulWidget {
  final ApiService apiService;

  const CompanySettingsScreen({super.key, required this.apiService});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _accountingFormKey = GlobalKey<FormState>();
  final _vatController = TextEditingController();
  String? _companyLogoUrl;
  bool _isLoading = false;
  bool _isSaving = false;
  AccountingSettings? _accountingSettings;
  List<Map<String, dynamic>> _accounts = [];
  late final AccountingSettingsService _accountingService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _accountingService = AccountingSettingsService(widget.apiService);
    _loadSettings();
    _loadAccountingSettings();
    _loadAccounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _vatController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get('/api/company/settings');
      
      if (response['companyName'] != null) {
        _companyNameController.text = response['companyName'];
      }
      if (response['companyLogoUrl'] != null) {
        _companyLogoUrl = response['companyLogoUrl'];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الإعدادات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadAccountingSettings() async {
    try {
      print('Loading accounting settings...');
      final settings = await _accountingService.getSettings();
      print('Accounting settings loaded: $settings');
      setState(() {
        _accountingSettings = settings;
        _vatController.text = settings.vatPercentage?.toString() ?? '';
        print('State updated with accounting settings');
      });
    } catch (e) {
      print('Error loading accounting settings: $e');
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final response = await widget.apiService.get('/api/accounts');
      print('Accounts response: $response');
      setState(() {
        _accounts = List<Map<String, dynamic>>.from(response);
        print('Loaded ${_accounts.length} accounts');
      });
    } catch (e) {
      print('Error loading accounts: $e');
    }
  }

  Future<void> _saveAccountingSettings() async {
    if (!_accountingFormKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updatedSettings = _accountingSettings!.copyWith(
        vatPercentage: double.tryParse(_vatController.text),
      );
      await _accountingService.updateSettings(updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الإعدادات المحاسبية بنجاح')),
        );
        await _loadAccountingSettings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ الإعدادات المحاسبية: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final response = await widget.apiService.patch(
        '/api/company/settings',
        body: {
          'companyName': _companyNameController.text,
          'companyLogoUrl': _companyLogoUrl,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ الإعدادات: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _showLogoUploadDialog() async {
    try {
      // Pick image file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم اختيار ملف صالح')),
          );
        }
        return;
      }

      // Show loading indicator
      if (mounted) {
        setState(() => _isSaving = true);
      }

      // Upload file
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/api/company/upload-logo'),
      );

      final fileStream = http.ByteStream(File(file.path!).openRead());
      final length = await File(file.path!).length();
      
      request.files.add(
        http.MultipartFile(
          'logo',
          fileStream,
          length,
          filename: file.name,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        if (responseData['logoUrl'] != null) {
          setState(() {
            _companyLogoUrl = '${ApiConstants.baseUrl}${responseData['logoUrl']}';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع الشعار بنجاح')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في رفع الشعار: ${responseData['error'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'معلومات الشركة'),
                    Tab(text: 'الإعدادات المحاسبية'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCompanyInfoTab(),
                      _buildAccountingSettingsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCompanyInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'إعدادات النظام',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات الشركة',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم الشركة',
                          hintText: 'مثال: Garage Go',
                          prefixIcon: Icon(Icons.business_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال اسم الشركة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('شعار الشركة'),
                                const SizedBox(height: 8),
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .dividerColor,
                                    ),
                                  ),
                                  child: _companyLogoUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(11),
                                          child: Image.network(
                                            _companyLogoUrl!,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_rounded,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'لا يوجد شعار',
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: _showLogoUploadDialog,
                                icon: const Icon(Icons.upload_rounded),
                                label: const Text('تغيير الشعار'),
                              ),
                              const SizedBox(height: 8),
                              if (_companyLogoUrl != null)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _companyLogoUrl = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete_rounded),
                                  label: const Text('إزالة الشعار'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _loadSettings,
                    child: const Text('إعادة تعيين'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('حفظ التغييرات'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountingSettingsTab() {
    if (_accountingSettings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Form(
          key: _accountingFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'الإعدادات المحاسبية',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الحسابات الافتراضية',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 24),
                      _buildAccountDropdown(
                        label: 'حساب إيرادات الخدمات',
                        value: _accountingSettings!.revenueServiceAccountId,
                        onChanged: (value) {
                          setState(() {
                            _accountingSettings = _accountingSettings!.copyWith(
                              revenueServiceAccountId: value!,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(
                        label: 'حساب إيرادات قطع الغيار',
                        value: _accountingSettings!.revenuePartsAccountId,
                        onChanged: (value) {
                          setState(() {
                            _accountingSettings = _accountingSettings!.copyWith(
                              revenuePartsAccountId: value!,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(
                        label: 'حساب تكلفة قطع الغيار',
                        value: _accountingSettings!.cogsPartsAccountId,
                        onChanged: (value) {
                          setState(() {
                            _accountingSettings = _accountingSettings!.copyWith(
                              cogsPartsAccountId: value!,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(
                        label: 'حساب المخزون',
                        value: _accountingSettings!.inventoryAccountId,
                        onChanged: (value) {
                          setState(() {
                            _accountingSettings = _accountingSettings!.copyWith(
                              inventoryAccountId: value!,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(
                        label: 'حساب الصندوق',
                        value: _accountingSettings!.cashAccountId,
                        onChanged: (value) {
                          setState(() {
                            _accountingSettings = _accountingSettings!.copyWith(
                              cashAccountId: value!,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(
                        label: 'حساب العملاء',
                        value: _accountingSettings!.receivableAccountId,
                        onChanged: (value) {
                          setState(() {
                            _accountingSettings = _accountingSettings!.copyWith(
                              receivableAccountId: value!,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAccountDropdown(
                        label: 'حساب الموردين',
                        value: _accountingSettings!.payableAccountId,
                        onChanged: (value) {
                          setState(() {
                            _accountingSettings = _accountingSettings!.copyWith(
                              payableAccountId: value!,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _vatController,
                        decoration: const InputDecoration(
                          labelText: 'نسبة ضريبة القيمة المضافة (%)',
                          prefixIcon: Icon(Icons.percent),
                          suffixText: '%',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final percentage = double.tryParse(value);
                            if (percentage == null || percentage < 0 || percentage > 100) {
                              return 'يرجى إدخال نسبة صحيحة (0-100)';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _loadAccountingSettings,
                    child: const Text('إعادة تعيين'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAccountingSettings,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('حفظ الإعدادات'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown({
    required String label,
    required int value,
    required Function(int?) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
      ),
      items: _accounts.map((account) {
        return DropdownMenuItem<int>(
          value: account['id'] as int,
          child: Text(
            '${account['code']} - ${account['nameAr']}',
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'يرجى اختيار حساب';
        }
        return null;
      },
    );
  }
}
