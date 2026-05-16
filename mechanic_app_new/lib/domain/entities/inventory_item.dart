class InventoryItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<InventoryVariant> variants;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.variants,
  });
}

class InventoryVariant {
  final String id;
  final String itemId;
  final String name;
  final String sku;
  final int quantity;
  final double? priceSYP;

  InventoryVariant({
    required this.id,
    required this.itemId,
    required this.name,
    required this.sku,
    required this.quantity,
    this.priceSYP,
  });

  bool get isAvailable => quantity > 0;
}
