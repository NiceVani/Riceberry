class SaleDetailModel {
  final int id;
  final int? saleId;
  final int? productId;
  final int quantity;
  final double unitPrice;

  SaleDetailModel({
    required this.id,
    this.saleId,
    this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  factory SaleDetailModel.fromJson(Map<String, dynamic> json) {
    return SaleDetailModel(
      id: json['sale_detail_id'] ?? 0,
      saleId: json['sale_id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}
