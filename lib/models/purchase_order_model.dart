class PurchaseOrderModel {
  final int id;
  final int? supplierId;
  final DateTime? purchaseDate;
  final double totalAmount;

  PurchaseOrderModel({
    required this.id,
    this.supplierId,
    this.purchaseDate,
    required this.totalAmount,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['purchase_id'] ?? 0,
      supplierId: json['supplier_id'],
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      // ปกติวันที่ฐานข้อมูลจะ Gen ให้เอง (DEFAULT NOW()) ตอน Insert อาจไม่ต้องส่งไป
      'purchase_date': purchaseDate?.toIso8601String(),
      'total_amount': totalAmount,
    };
  }
}
