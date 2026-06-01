class CropSale {
  const CropSale({
    required this.id,
    this.harvestId,
    required this.farmId,
    required this.cropId,
    required this.saleDate,
    required this.quantityTons,
    required this.pricePerTonZar,
    required this.totalAmountZar,
    this.buyer,
    required this.paymentStatus,
  });

  final String id;
  final String? harvestId;
  final String farmId;
  final String cropId;
  final DateTime saleDate;
  final double quantityTons;
  final double pricePerTonZar;
  final double totalAmountZar;
  final String? buyer;
  final String paymentStatus;

  factory CropSale.fromJson(Map<String, dynamic> json) => CropSale(
        id: json['id'] as String,
        harvestId: json['harvest_id'] as String?,
        farmId: json['farm_id'] as String,
        cropId: json['crop_id'] as String,
        saleDate: DateTime.parse(json['sale_date'] as String),
        quantityTons: (json['quantity_tons'] as num).toDouble(),
        pricePerTonZar: (json['price_per_ton_zar'] as num).toDouble(),
        totalAmountZar: (json['total_amount_zar'] as num).toDouble(),
        buyer: json['buyer'] as String?,
        paymentStatus: json['payment_status'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'harvest_id': harvestId,
    'farm_id': farmId,
    'crop_id': cropId,
    'sale_date': saleDate.toIso8601String(),
    'quantity_tons': quantityTons,
    'price_per_ton_zar': pricePerTonZar,
    'total_amount_zar': totalAmountZar,
    'buyer': buyer,
    'payment_status': paymentStatus,
  };

  bool get isPaid => paymentStatus == 'paid';
}
