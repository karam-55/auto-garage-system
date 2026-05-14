import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class InventoryItem {
  final String id;
  final String name;
  final String? category;
  final String? unit;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    this.category,
    this.unit,
    this.lowStockThreshold = 5,
    required this.createdAt,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      lowStockThreshold: json['lowStockThreshold'] as int? ?? 5,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
}

class InventoryScreen extends StatefulWidget {
  final ApiService apiService;

  const InventoryScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem> _items = [];
  List<InventoryItem> _filteredItems = [];
  List<InventoryItem> _lowStockItems = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _thresholdController = TextEditingController();
  String? _selectedCategory;
  Timer? _lowStockCheckTimer;
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_filterItems);
    _startLowStockCheck();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _thresholdController.dispose();
    _lowStockCheckTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startLowStockCheck() {
    _lowStockCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkLowStock();
    });
  }

  Future<void> _checkLowStock() async {
    try {
      final response = await widget.apiService.get('/api/inventory/low-stock');
      final lowStockItems = (response as List).map((item) => InventoryItem.fromJson(item)).toList();
      
      if (lowStockItems.isNotEmpty && mounted) {
        setState(() => _lowStockItems = lowStockItems);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تحذير: ${lowStockItems.length} صنف في المخزون المنخفض'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'عرض',
              textColor: Colors.white,
              onPressed: () {
                setState(() => _filteredItems = lowStockItems);
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Silent fail for background check
    }
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get('/api/inventory/items');
      final items = (response as List).map((item) => InventoryItem.fromJson(item)).toList();
      setState(() {
        _items = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load inventory: $e')),
        );
      }
    }
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final nameMatch = item.name.toLowerCase().contains(query);
        final categoryMatch = item.category?.toLowerCase().contains(query) ?? false;
        return nameMatch || categoryMatch;
      }).toList();
    });
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await widget.apiService.post(
        '/api/inventory/items',
        {
          'name': _nameController.text,
          'category': _categoryController.text.isEmpty ? null : _categoryController.text,
          'unit': _unitController.text.isEmpty ? null : _unitController.text,
          'lowStockThreshold': int.tryParse(_thresholdController.text) ?? 5,
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الصنف بنجاح')),
        );
        _loadItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إضافة الصنف: $e')),
        );
      }
    }
  }

  Future<void> _editItem(InventoryItem item) async {
    _nameController.text = item.name;
    _categoryController.text = item.category ?? '';
    _unitController.text = item.unit ?? '';
    _thresholdController.text = item.lowStockThreshold.toString();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الصنف'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم الصنف'),
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                ),
                TextFormField(
                  controller: _unitController,
                  decoration: const InputDecoration(labelText: 'الوحدة'),
                ),
                TextFormField(
                  controller: _thresholdController,
                  decoration: const InputDecoration(labelText: 'الحد الأدنى للمخزون'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await widget.apiService.put(
                    '/api/inventory/items/${item.id}',
                    {
                      'name': _nameController.text,
                      'category': _categoryController.text.isEmpty ? null : _categoryController.text,
                      'unit': _unitController.text.isEmpty ? null : _unitController.text,
                      'lowStockThreshold': int.tryParse(_thresholdController.text) ?? 5,
                    },
                  );
                  if (mounted) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم تحديث الصنف بنجاح')),
                    );
                    _loadItems();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update item: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true) {
      _clearControllers();
    }
  }

  Future<void> _deleteItem(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${item.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.apiService.delete('/api/inventory/items/${item.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الصنف بنجاح')),
          );
          _loadItems();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete item: $e')),
          );
        }
      }
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _categoryController.clear();
    _unitController.clear();
    _thresholdController.clear();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المخزون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItems,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'بحث',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? const Center(child: Text('لا توجد أصناف'))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _currentPage * _pageSize < _filteredItems.length
                                  ? _pageSize
                                  : _filteredItems.length - (_currentPage - 1) * _pageSize,
                              itemBuilder: (context, index) {
                                final itemIndex = (_currentPage - 1) * _pageSize + index;
                                if (itemIndex >= _filteredItems.length) return null;
                                final item = _filteredItems[itemIndex];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(item.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (item.category != null) Text('التصنيف: ${item.category}'),
                                        if (item.unit != null) Text('الوحدة: ${item.unit}'),
                                        Text('الحد الأدنى: ${item.lowStockThreshold}'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editItem(item),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteItem(item),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => InventoryVariantsScreen(
                                            apiService: widget.apiService,
                                            itemId: item.id,
                                            itemName: item.name,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_filteredItems.length > _pageSize)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                  ),
                                  Text('صفحة $_currentPage من ${(_filteredItems.length / _pageSize).ceil()}'),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: _currentPage * _pageSize < _filteredItems.length
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearControllers();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('إضافة صنف جديد'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'اسم الصنف'),
                        validator: (value) => value?.isEmpty ?? true ? 'مطلوب' : null,
                      ),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'التصنيف'),
                      ),
                      TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(labelText: 'الوحدة'),
                      ),
                      TextFormField(
                        controller: _thresholdController,
                        decoration: const InputDecoration(labelText: 'الحد الأدنى للمخزون'),
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
                ElevatedButton(
                  onPressed: _addItem,
                  child: const Text('إضافة'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InventoryVariant {
  final String id;
  final String itemId;
  final String variantType;
  final int quantity;
  final double costPrice;
  final double sellingPrice;
  final String? supplier;
  final DateTime createdAt;

  InventoryVariant({
    required this.id,
    required this.itemId,
    required this.variantType,
    this.quantity = 0,
    this.costPrice = 0,
    this.sellingPrice = 0,
    this.supplier,
    required this.createdAt,
  });

  factory InventoryVariant.fromJson(Map<String, dynamic> json) {
    return InventoryVariant(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      variantType: json['variantType'] as String,
      quantity: json['quantity'] as int? ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0,
      supplier: json['supplier'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class InventoryVariantsScreen extends StatefulWidget {
  final ApiService apiService;
  final String itemId;
  final String itemName;

  const InventoryVariantsScreen({
    Key? key,
    required this.apiService,
    required this.itemId,
    required this.itemName,
  }) : super(key: key);

  @override
  State<InventoryVariantsScreen> createState() => _InventoryVariantsScreenState();
}

class _InventoryVariantsScreenState extends State<InventoryVariantsScreen> {
  List<InventoryVariant> _variants = [];
  bool _isLoading = true;
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  String _selectedVariantType = 'ORIGINAL';

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  @override
  void dispose() {
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  Future<void> _loadVariants() async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.apiService.get('/api/inventory/items/${widget.itemId}/variants');
      final variants = (response as List).map((item) => InventoryVariant.fromJson(item)).toList();
      setState(() {
        _variants = variants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load variants: $e')),
        );
      }
    }
  }

  Future<void> _addVariant() async {
    try {
      await widget.apiService.post(
        '/api/inventory/variants',
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'itemId': widget.itemId,
          'variantType': _selectedVariantType,
          'quantity': int.tryParse(_quantityController.text) ?? 0,
          'costPrice': double.tryParse(_costPriceController.text) ?? 0,
          'sellingPrice': double.tryParse(_sellingPriceController.text) ?? 0,
          'supplier': _supplierController.text.isEmpty ? null : _supplierController.text,
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة النوع بنجاح')),
        );
        _loadVariants();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add variant: $e')),
        );
      }
    }
  }

  Future<void> _updateVariant(InventoryVariant variant) async {
    _costPriceController.text = variant.costPrice.toString();
    _sellingPriceController.text = variant.sellingPrice.toString();
    _quantityController.text = variant.quantity.toString();
    _supplierController.text = variant.supplier ?? '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل النوع'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('النوع: ${variant.variantType}'),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'الكمية'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _costPriceController,
                decoration: const InputDecoration(labelText: 'سعر الشراء'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(labelText: 'سعر البيع'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _supplierController,
                decoration: const InputDecoration(labelText: 'المورد'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.apiService.put(
                  '/api/inventory/variants/${variant.id}',
                  {
                    'quantity': int.tryParse(_quantityController.text) ?? 0,
                    'costPrice': double.tryParse(_costPriceController.text) ?? 0,
                    'sellingPrice': double.tryParse(_sellingPriceController.text) ?? 0,
                    'supplier': _supplierController.text.isEmpty ? null : _supplierController.text,
                  },
                );
                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث النوع بنجاح')),
                  );
                  _loadVariants();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update variant: $e')),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    if (result == true) {
      _clearControllers();
    }
  }

  Future<void> _deleteVariant(InventoryVariant variant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا النوع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.apiService.delete('/api/inventory/variants/${variant.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف النوع بنجاح')),
          );
          _loadVariants();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete variant: $e')),
          );
        }
      }
    }
  }

  void _clearControllers() {
    _costPriceController.clear();
    _sellingPriceController.clear();
    _quantityController.clear();
    _supplierController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أنواع ${widget.itemName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _variants.isEmpty
              ? const Center(child: Text('لا توجد أنواع'))
              : ListView.builder(
                  itemCount: _variants.length,
                  itemBuilder: (context, index) {
                    final variant = _variants[index];
                    final variantTypeArabic = {
                      'ORIGINAL': 'أصلي',
                      'COMMERCIAL': 'تجاري',
                      'USED': 'مستعمل',
                    }[variant.variantType] ?? variant.variantType;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(variantTypeArabic),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الكمية: ${variant.quantity}'),
                            Text('سعر الشراء: ${variant.costPrice} ل.س'),
                            Text('سعر البيع: ${variant.sellingPrice} ل.س'),
                            if (variant.supplier != null) Text('المورد: ${variant.supplier}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _updateVariant(variant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteVariant(variant),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearControllers();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('إضافة نوع جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedVariantType,
                      decoration: const InputDecoration(labelText: 'النوع'),
                      items: const [
                        DropdownMenuItem(value: 'ORIGINAL', child: Text('أصلي')),
                        DropdownMenuItem(value: 'COMMERCIAL', child: Text('تجاري')),
                        DropdownMenuItem(value: 'USED', child: Text('مستعمل')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedVariantType = value!);
                      },
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'الكمية'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(labelText: 'سعر الشراء'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(labelText: 'سعر البيع'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _supplierController,
                      decoration: const InputDecoration(labelText: 'المورد'),
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
                  onPressed: _addVariant,
                  child: const Text('إضافة'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
