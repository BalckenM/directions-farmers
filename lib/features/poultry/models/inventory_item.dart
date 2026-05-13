/// Inventory item category.
enum InventoryCategory {
  feed,
  vaccine,
  medication,
  equipment,
  bedding,
  other;

  static InventoryCategory fromString(String value) => switch (value) {
        'feed' => feed,
        'vaccine' => vaccine,
        'medication' => medication,
        'equipment' => equipment,
        'bedding' => bedding,
        _ => other,
      };

  String get label => switch (this) {
        InventoryCategory.feed => 'Feed',
        InventoryCategory.vaccine => 'Vaccine',
        InventoryCategory.medication => 'Medication',
        InventoryCategory.equipment => 'Equipment',
        InventoryCategory.bedding => 'Bedding',
        InventoryCategory.other => 'Other',
      };
}

/// A single farm inventory item (feed, medication, vaccine, equipment, etc.).
class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.farmId,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minThreshold,
    required this.pricePerUnit,
    this.lastDeliveryDate,
    this.supplierId,
    this.notes,
  });

  final String id;
  final String farmId;
  final String name;
  final InventoryCategory category;
  final String unit;
  final double currentStock;
  final double minThreshold;
  final double pricePerUnit;
  final String? lastDeliveryDate;
  final String? supplierId;
  final String? notes;

  /// True when the on-hand stock has fallen below the reorder threshold.
  bool get isBelowThreshold => currentStock < minThreshold;

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as String,
        farmId: json['farm_id'] as String,
        name: json['name'] as String,
        category: InventoryCategory.fromString(json['category'] as String),
        unit: json['unit'] as String,
        currentStock: (json['current_stock'] as num).toDouble(),
        minThreshold: (json['min_threshold'] as num).toDouble(),
        pricePerUnit: (json['price_per_unit'] as num).toDouble(),
        lastDeliveryDate: json['last_delivery_date'] as String?,
        supplierId: json['supplier_id'] as String?,
        notes: json['notes'] as String?,
      );
}
