import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_variant.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/alert.dart' as alert_domain;
import '../../domain/repositories/inventory_item_repository.dart';
import '../../domain/repositories/inventory_variant_repository.dart';
import '../../domain/repositories/inventory_transaction_repository.dart';
import '../../domain/repositories/booking_invoice_data_repository.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/journal_repository.dart';
import '../middlewares/auth_middleware.dart';
import '../../application/services/journal_service.dart';
import '../../application/services/accounting_settings_service.dart';

class InventoryRoutes {
  final InventoryItemRepository _itemRepository;
  final InventoryVariantRepository _variantRepository;
  final InventoryTransactionRepository _transactionRepository;
  final BookingInvoiceDataRepository _invoiceDataRepository;
  final AlertRepository _alertRepository;
  final AuthMiddleware _authMiddleware;
  final AccountRepository _accountRepository;
  final JournalRepository _journalRepository;
  final JournalService _journalService;
  final AccountingSettingsService _accountingSettingsService;

  InventoryRoutes(
    this._itemRepository,
    this._variantRepository,
    this._transactionRepository,
    this._invoiceDataRepository,
    this._alertRepository,
    this._authMiddleware,
    this._accountRepository,
    this._journalRepository,
    this._journalService,
    this._accountingSettingsService,
  );

  Router get router {
    final router = Router();

    // Inventory Items CRUD
    router.get('/api/inventory/items', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getAllItems)));
    router.get('/api/inventory/items/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getItemById)));
    router.post('/api/inventory/items', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_createItem)));
    router.put('/api/inventory/items/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_updateItem)));
    router.delete('/api/inventory/items/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteItem)));

    // Inventory Variants CRUD
    router.get('/api/inventory/variants', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getAllVariants)));
    router.get('/api/inventory/variants/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getVariantById)));
    router.get('/api/inventory/items/<itemId>/variants', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getVariantsByItemId)));
    router.post('/api/inventory/variants', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_createVariant)));
    router.put('/api/inventory/variants/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MANAGER)(_updateVariant)));
    router.delete('/api/inventory/variants/<id>', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.OWNER)(_deleteVariant)));

    // Low stock endpoint
    router.get('/api/inventory/low-stock', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.RECEPTIONIST)(_getLowStock)));

    // Consume parts endpoint
    router.post('/api/inventory/consume', _authMiddleware.authenticate()(_authMiddleware.requireRole(Role.MECHANIC)(_consumePart)));

    return router;
  }

  // Inventory Items handlers
  Future<Response> _getAllItems(Request request) async {
    try {
      final items = await _itemRepository.findAll();
      return Response.ok(
        jsonEncode(items.map((item) => item.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get inventory items: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getItemById(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid item ID'}));
    }
    try {
      final item = await _itemRepository.findById(id);
      if (item == null) {
        return Response.notFound(
          jsonEncode({'error': 'Inventory item not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      return Response.ok(
        jsonEncode(item.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get inventory item: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _createItem(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // Generate ID if not provided
      final id = data['id'] ?? const Uuid().v4();

      final item = InventoryItem(
        id: id,
        name: data['name'] as String,
        category: data['category'] as String?,
        unit: data['unit'] as String?,
        lowStockThreshold: data['lowStockThreshold'] as int? ?? 5,
        createdAt: DateTime.now().toUtc(),
      );

      final result = await _itemRepository.create(item);
      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create inventory item: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateItem(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid item ID'}));
    }
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final existing = await _itemRepository.findById(id);
      if (existing == null) {
        return Response.notFound(
          jsonEncode({'error': 'Inventory item not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final item = existing.copyWith(
        name: data['name'] as String? ?? existing.name,
        category: data['category'] as String?,
        unit: data['unit'] as String?,
        lowStockThreshold: data['lowStockThreshold'] as int? ?? existing.lowStockThreshold,
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _itemRepository.update(item);
      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update inventory item: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteItem(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid item ID'}));
    }
    try {
      await _itemRepository.delete(id);
      return Response.ok(
        jsonEncode({'message': 'Inventory item deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete inventory item: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Inventory Variants handlers
  Future<Response> _getAllVariants(Request request) async {
    try {
      final variants = await _variantRepository.findAll();
      return Response.ok(
        jsonEncode(variants.map((variant) => variant.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get inventory variants: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getVariantById(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid variant ID'}));
    }
    try {
      final variant = await _variantRepository.findById(id);
      if (variant == null) {
        return Response.notFound(
          jsonEncode({'error': 'Inventory variant not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
      return Response.ok(
        jsonEncode(variant.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get inventory variant: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getVariantsByItemId(Request request) async {
    final itemId = request.params['itemId'];
    if (itemId == null || itemId.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid item ID'}));
    }
    try {
      final variants = await _variantRepository.findByItemId(itemId);
      return Response.ok(
        jsonEncode(variants.map((variant) => variant.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get inventory variants: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _createVariant(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // Generate ID if not provided
      final id = data['id'] ?? const Uuid().v4();

      final variant = InventoryVariant(
        id: id,
        itemId: data['itemId'] as String,
        variantType: VariantType.fromString(data['variantType'] as String),
        quantity: data['quantity'] as int? ?? 0,
        costPrice: (data['costPrice'] is num ? data['costPrice'] as num : double.tryParse(data['costPrice'] as String? ?? '0'))?.toDouble() ?? 0,
        sellingPrice: (data['sellingPrice'] is num ? data['sellingPrice'] as num : double.tryParse(data['sellingPrice'] as String? ?? '0'))?.toDouble() ?? 0,
        supplier: data['supplier'] as String?,
        createdAt: DateTime.now().toUtc(),
      );

      final result = await _variantRepository.create(variant);
      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create inventory variant: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateVariant(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid variant ID'}));
    }
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final existing = await _variantRepository.findById(id);
      if (existing == null) {
        return Response.notFound(
          jsonEncode({'error': 'Inventory variant not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final variant = existing.copyWith(
        quantity: data['quantity'] as int? ?? existing.quantity,
        costPrice: (data['costPrice'] as num?)?.toDouble() ?? existing.costPrice,
        sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? existing.sellingPrice,
        supplier: data['supplier'] as String?,
      );

      final result = await _variantRepository.update(variant);
      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update inventory variant: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _deleteVariant(Request request) async {
    final id = request.params['id'];
    if (id == null || id.isEmpty) {
      return Response.badRequest(body: jsonEncode({'error': 'Invalid variant ID'}));
    }
    try {
      await _variantRepository.delete(id);
      return Response.ok(
        jsonEncode({'message': 'Inventory variant deleted successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete inventory variant: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Low stock handler
  Future<Response> _getLowStock(Request request) async {
    try {
      final items = await _itemRepository.findLowStock();
      return Response.ok(
        jsonEncode(items.map((item) => item.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get low stock items: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // Consume part handler
  Future<Response> _consumePart(Request request) async {
    try {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final variantId = data['variantId'] as String;
      final quantity = data['quantity'] as int;
      final bookingId = data['bookingId'] as String?;
      
      // Get variant
      final variant = await _variantRepository.findById(variantId);
      if (variant == null) {
        return Response.notFound(
          jsonEncode({'error': 'Inventory variant not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if enough quantity
      if (variant.quantity < quantity) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Insufficient quantity. Available: ${variant.quantity}, Requested: $quantity'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Get item
      final item = await _itemRepository.findById(variant.itemId);
      if (item == null) {
        return Response.notFound(
          jsonEncode({'error': 'Inventory item not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Update variant quantity
      final updatedVariant = variant.copyWith(quantity: variant.quantity - quantity);
      await _variantRepository.update(updatedVariant);

      // Create transaction record
      final transaction = InventoryTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: item.id,
        variantId: variant.id,
        bookingId: bookingId,
        type: TransactionType.consume,
        quantity: quantity,
        createdAt: DateTime.now().toUtc(),
      );

      await _transactionRepository.create(transaction);

      // Create accounting journal entry for COGS
      try {
        final accountingSettings = await _accountingSettingsService.getSettings();
        final totalCost = quantity * (variant.costPrice > 0 ? variant.costPrice : variant.sellingPrice * 0.7);
        
        await _journalService.createJournalEntry(
          date: DateTime.now(),
          reference: 'CONS-${bookingId?.substring(0, 8) ?? DateTime.now().millisecondsSinceEpoch.toString()}',
          description: 'استهلاك قطع غيار للحجز $bookingId',
          lines: [
            JournalLineInput(
              accountId: accountingSettings.cogsPartsAccountId,
              debit: totalCost,
              credit: 0,
              description: 'تكلفة ${item.name} (${variant.variantType})',
            ),
            JournalLineInput(
              accountId: accountingSettings.inventoryAccountId,
              debit: 0,
              credit: totalCost,
              description: 'تخفيض المخزون - ${item.name}',
            ),
          ],
          sourceType: 'booking_consume',
          sourceId: bookingId ?? variantId,
          createdBy: request.context['user'] != null ? (request.context['user'] as dynamic).id : null,
        );
      } catch (e) {
        // Don't fail the request if journal entry creation fails
      }

      // Regenerate invoice if bookingId is provided
      if (bookingId != null) {
        try {
          await _invoiceDataRepository.generateOrGetInvoice(bookingId);
        } catch (e) {
          // Don't fail the request if invoice generation fails
        }
      }

      // Check for low stock alert
      if (updatedVariant.quantity <= item.lowStockThreshold) {
        try {
          await _alertRepository.create(
            alert_domain.Alert(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: alert_domain.AlertType.lowStock,
              relatedId: variant.id,
              message: 'تنبيه: ${item.name} (${variant.variantType}) وصل للحد الأدنى (${updatedVariant.quantity})',
              isRead: false,
              createdAt: DateTime.now().toUtc(),
            ),
          );
          
          // Note: WebSocket broadcast removed due to removal of WebSocket support
        } catch (e) {
          // Don't fail the request if alert creation fails
        }
      }

      return Response.ok(
        jsonEncode({
          'message': 'Part consumed successfully',
          'remainingQuantity': updatedVariant.quantity,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to consume part: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
