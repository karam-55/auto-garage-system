import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import 'dart:convert';

class HrScreen extends StatefulWidget {
  final ApiService apiService;

  const HrScreen({super.key, required this.apiService});

  @override
  State<HrScreen> createState() => _HrScreenState();
}

class _HrScreenState extends State<HrScreen> {
  List<dynamic> contracts = [];
  List<dynamic> leaveRequests = [];
  List<dynamic> performanceReviews = [];
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
      final contractsResponse = await widget.apiService.get(ApiConstants.hrContracts);
      final leavesResponse = await widget.apiService.get(ApiConstants.hrLeaveRequests);
      final reviewsResponse = await widget.apiService.get(ApiConstants.hrPerformanceReviews);

      if (contractsResponse is List) {
        setState(() {
          contracts = contractsResponse;
          isLoading = false;
        });
      }
      if (leavesResponse is List) {
        setState(() {
          leaveRequests = leavesResponse;
        });
      }
      if (reviewsResponse is List) {
        setState(() {
          performanceReviews = reviewsResponse;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الموارد البشرية'),
        bottom: TabBar(
          onTap: (index) => setState(() => selectedTabIndex = index),
          tabs: const [
            Tab(text: 'العقود'),
            Tab(text: 'طلبات الإجازة'),
            Tab(text: 'تقييمات الأداء'),
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
                _buildContractsTab(),
                _buildLeaveRequestsTab(),
                _buildPerformanceReviewsTab(),
              ],
            ),
    );
  }

  Widget _buildContractsTab() {
    return ListView.builder(
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(contract['employee_name']?.toString()[0] ?? ''),
            ),
            title: Text(contract['employee_name'] ?? ''),
            subtitle: Text('${contract['start_date']} - ${contract['end_date']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditContractDialog(contract),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteContract(contract['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveRequestsTab() {
    return ListView.builder(
      itemCount: leaveRequests.length,
      itemBuilder: (context, index) {
        final request = leaveRequests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(request['employee_name']?.toString()[0] ?? ''),
            ),
            title: Text(request['employee_name'] ?? ''),
            subtitle: Text('${request['start_date']} - ${request['end_date']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (request['status'] == 'pending')
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _approveLeaveRequest(request['id']),
                  ),
                if (request['status'] == 'pending')
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectLeaveRequest(request['id']),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteLeaveRequest(request['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceReviewsTab() {
    return ListView.builder(
      itemCount: performanceReviews.length,
      itemBuilder: (context, index) {
        final review = performanceReviews[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(review['employee_name']?.toString()[0] ?? ''),
            ),
            title: Text(review['employee_name'] ?? ''),
            subtitle: Text('${review['review_period']} - التقييم: ${review['rating']}/5'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deletePerformanceReview(review['id']),
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateContractDialog(),
    );
  }

  void _showEditContractDialog(dynamic contract) {
    showDialog(
      context: context,
      builder: (context) => CreateContractDialog(contract: contract),
    );
  }

  void _deleteContract(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العقد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _approveLeaveRequest(int id) async {
    try {
      await widget.apiService.put(ApiConstants.hrLeaveRequestApprove(id.toString()), {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول طلب الإجازة')),
      );
      fetchData();
    } catch (e) {
    }
  }

  void _rejectLeaveRequest(int id) async {
    try {
      await widget.apiService.put(ApiConstants.hrLeaveRequestReject(id.toString()), {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض طلب الإجازة')),
      );
      fetchData();
    } catch (e) {
    }
  }

  void _deleteLeaveRequest(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _deletePerformanceReview(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا التقييم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class CreateContractDialog extends StatefulWidget {
  final dynamic contract;

  const CreateContractDialog({super.key, this.contract});

  @override
  State<CreateContractDialog> createState() => _CreateContractDialogState();
}

class _CreateContractDialogState extends State<CreateContractDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _employeeIdController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    _employeeIdController = TextEditingController(text: widget.lead?['employee_id']?.toString() ?? '');
    _startDateController = TextEditingController(text: widget.lead?['start_date'] ?? '');
    _endDateController = TextEditingController(text: widget.lead?['end_date'] ?? '');
    _salaryController = TextEditingController(text: widget.lead?['salary']?.toString() ?? '');
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contract == null ? 'إضافة عقد جديد' : 'تعديل العقد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(labelText: 'معرف الموظف'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'تاريخ البدء'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'تاريخ الانتهاء'),
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
              ),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'الراتب'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
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
              Navigator.pop(context);
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
