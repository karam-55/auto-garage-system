import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mechanic_provider.dart';
import '../../models/mechanic_assignment.dart';

class MyAssignmentsScreen extends StatefulWidget {
  const MyAssignmentsScreen({super.key});

  @override
  State<MyAssignmentsScreen> createState() => _MyAssignmentsScreenState();
}

class _MyAssignmentsScreenState extends State<MyAssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MechanicProvider>().fetchMyAssignments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مهامي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MechanicProvider>().fetchMyAssignments(),
          ),
        ],
      ),
      body: Consumer<MechanicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myAssignments.isEmpty) {
            return const Center(child: Text('لا توجد مهام مُسندة إليك'));
          }

          return ListView.builder(
            itemCount: provider.myAssignments.length,
            itemBuilder: (context, index) {
              final assignment = provider.myAssignments[index];
              return _buildAssignmentCard(assignment, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(MechanicAssignment assignment, MechanicProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Text(assignment.id.substring(0, 2)),
        ),
        title: Text('مهمة #${assignment.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحالة: ${assignment.statusDisplay}'),
            Text('تاريخ الاستلام: ${assignment.assignedAt.toString().substring(0, 16)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (assignment.notes != null) Text('ملاحظات: ${assignment.notes}'),
                const SizedBox(height: 16),
                const Text('تحديث الحالة:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateStatus(assignment, 'IN_PROGRESS', provider),
                      child: const Text('قيد العمل'),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateStatus(assignment, 'WAITING_PARTS', provider),
                      child: const Text('بانتظار القطع'),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateStatus(assignment, 'READY', provider),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('جاهز'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'إضافة ملاحظات فنية',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSubmitted: (notes) => _updateStatus(assignment, assignment.status, provider, notes),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showPartSuggestionDialog(context, assignment.bookingId, provider),
                  icon: const Icon(Icons.add_circle),
                  label: const Text('إقتراح قطعة'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(MechanicAssignment assignment, String status, MechanicProvider provider, [String? notes]) async {
    final success = await provider.updateAssignmentStatus(assignment.id, status, notes);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الحالة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPartSuggestionDialog(BuildContext context, String bookingId, MechanicProvider provider) {
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إقتراح قطعة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem(value: 'ORIGINAL', child: Text('أصلي')),
                  DropdownMenuItem(value: 'COMMERCIAL', child: Text('تجاري')),
                  DropdownMenuItem(value: 'USED', child: Text('مستعمل')),
                ],
                onChanged: (value) => typeController.text = value ?? '',
                decoration: const InputDecoration(labelText: 'نوع القطعة'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'السعر (ل.س)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.createPartSuggestion(
                bookingId,
                typeController.text,
                descriptionController.text,
                priceController.text.isEmpty ? null : double.parse(priceController.text),
              );
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال الإقتراح بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}
