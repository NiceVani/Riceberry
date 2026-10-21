class SaleOrderModel {
  final int id;
  final String? customerName;
  final DateTime? saleDate;
  final double totalAmount;

  SaleOrderModel({
    required this.id,
    this.customerName,
    this.saleDate,
    required this.totalAmount,
  });

  factory SaleOrderModel.fromJson(Map<String, dynamic> json) {
    return SaleOrderModel(
      id: json['sale_id'] ?? 0,
      customerName: json['customer_name'],
      saleDate: json['sale_date'] != null
          ? DateTime.parse(json['sale_date'])
          : null,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'sale_date': saleDate?.toIso8601String(),
      'total_amount': totalAmount,
    };
  }
}
