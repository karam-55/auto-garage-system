import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../core/services/api_service.dart';
import '../core/widgets/professional_dialog.dart';
import '../core/constants/api_constants.dart';

class CompanySettingsScreen extends StatefulWidget {
  final ApiService apiService;

  const CompanySettingsScreen({super.key, required this.apiService});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  String? _companyLogoUrl;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get('/company/settings');
      
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

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final response = await widget.apiService.patch(
        '/company/settings',
        data: {
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
      
      // Add authorization header if available
      final token = await widget.apiService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

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
          : SingleChildScrollView(
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
            ),
    );
  }
}
