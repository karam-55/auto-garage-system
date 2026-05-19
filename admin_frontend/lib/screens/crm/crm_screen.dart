import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CrmScreen extends StatefulWidget {
  const CrmScreen({super.key});

  @override
  State<CrmScreen> createState() => _CrmScreenState();
}

class _CrmScreenState extends State<CrmScreen> {
  List<dynamic> leads = [];
  List<dynamic> activities = [];
  bool isLoading = true;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final baseUrl = 'YOUR_API_URL';
      
      final leadsResponse = await http.get(
        Uri.parse('$baseUrl/crm/leads'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );
      final activitiesResponse = await http.get(
        Uri.parse('$baseUrl/crm/activities'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );

      if (leadsResponse.statusCode == 200) {
        setState(() {
          leads = jsonDecode(leadsResponse.body);
          isLoading = false;
        });
      }
      if (activitiesResponse.statusCode == 200) {
        setState(() {
          activities = jsonDecode(activitiesResponse.body);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة علاقات العملاء'),
        bottom: TabBar(
          onTap: (index) => setState(() => selectedTabIndex = index),
          tabs: const [
            Tab(text: 'العملاء المحتملين'),
            Tab(text: 'الأنشطة'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedTabIndex,
              children: [
                _buildLeadsTab(),
              _buildActivitiesTab(),
              ],
            ),
    );
  }

  Widget _buildLeadsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'بحث عن عميل محتمل...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(lead['name']?.toString()[0] ?? ''),
                  ),
                  title: Text(lead['name'] ?? ''),
                  subtitle: Text('${lead['email'] ?? ''} - ${lead['phone'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (lead['status'] != 'converted')
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () => _convertLead(lead['id']),
                          tooltip: 'تحويل إلى عميل',
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(lead),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteLead(lead['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'بحث عن نشاط...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Icon(_getActivityIcon(activity['type'])),
                  title: Text(activity['description'] ?? ''),
                  subtitle: Text('${activity['date'] ?? ''} - ${activity['lead_name'] ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteActivity(activity['id']),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'call':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'meeting':
        return Icons.meeting_room;
      case 'note':
        return Icons.note;
      default:
        return Icons.event;
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateLeadDialog(),
    );
  }

  void _showEditDialog(dynamic lead) {
    showDialog(
      context: context,
      builder: (context) => CreateLeadDialog(lead: lead),
    );
  }

  void _convertLead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('YOUR_API_URL/crm/leads/$id/convert'),
        headers: {'Authorization': 'Bearer YOUR_TOKEN'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحويل العميل المحتمل بنجاح')),
        );
        fetchData();
      }
    } catch (e) {
      print('Error converting lead: $e');
    }
  }

  void _deleteLead(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العميل المحتمل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _deleteActivity(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا النشاط؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class CreateLeadDialog extends StatefulWidget {
  final dynamic lead;

  const CreateLeadDialog({super.key, this.lead});

  @override
  State<CreateLeadDialog> createState() => _CreateLeadDialogState();
}

class _CreateLeadDialogState extends State<CreateLeadDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late String _status;

  final List<String> statuses = ['new', 'contacted', 'qualified', 'proposal', 'converted', 'lost'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead?['name'] ?? '');
    _emailController = TextEditingController(text: widget.lead?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.lead?['phone'] ?? '');
    _companyController = TextEditingController(text: widget.lead?['company'] ?? '');
    _status = widget.lead?['status'] ?? 'new';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lead == null ? 'إضافة عميل محتمل جديد' : 'تعديل العميل المحتمل'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'الشركة'),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Implement save
              Navigator.pop(context);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
