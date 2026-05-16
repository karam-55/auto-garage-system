import '../../domain/entities/inventory_item.dart';

class InventoryItemModel extends InventoryItem {
  InventoryItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.variants,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    final variantsList = (json['variants'] as List<dynamic>?)
            ?.map((v) => InventoryVariantModel.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];

    return InventoryItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      variants: variantsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'variants': variants.map((v) => (v as InventoryVariantModel).toJson()).toList(),
    };
  }

  InventoryItem toEntity() => InventoryItem(
        id: id,
        name: name,
        description: description,
        category: category,
        variants: variants.map((v) => (v as InventoryVariantModel).toEntity()).toList(),
      );
}

class InventoryVariantModel extends InventoryVariant {
  InventoryVariantModel({
    required super.id,
    required super.itemId,
    required super.name,
    required super.sku,
    required super.quantity,
    super.priceSYP,
  });

  factory InventoryVariantModel.fromJson(Map<String, dynamic> json) {
    return InventoryVariantModel(
      id: json['id'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      priceSYP: json['price_syp'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'name': name,
      'sku': sku,
      'quantity': quantity,
      'price_syp': priceSYP,
    };
  }

  InventoryVariant toEntity() => InventoryVariant(
        id: id,
        itemId: itemId,
        name: name,
        sku: sku,
        quantity: quantity,
        priceSYP: priceSYP,
      );
}
