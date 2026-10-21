class PurchaseDetailModel {
  final int id;
  final int? purchaseId;
  final int? productId;
  final int quantity;
  final double unitPrice;

  PurchaseDetailModel({
    required this.id,
    this.purchaseId,
    this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory PurchaseDetailModel.fromJson(Map<String, dynamic> json) {
    return PurchaseDetailModel(
      id: json['purchase_detail_id'] ?? 0,
      purchaseId: json['purchase_id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchase_id': purchaseId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}
