class ProductInventoryModel {
  final int id;
  final String name;
  final int quantityInStock;
  final int? unitId; // อ้างอิง ID ของหน่วยนับ

  ProductInventoryModel({
    required this.id,
    required this.name,
    required this.quantityInStock,
    this.unitId,
  });

  factory ProductInventoryModel.fromJson(Map<String, dynamic> json) {
    return ProductInventoryModel(
      id: json['product_id'] ?? 0,
      name: json['product_name'] ?? '',
      quantityInStock: json['quantity_in_stock'] ?? 0,
      unitId: json['unit_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': name,
      'quantity_in_stock': quantityInStock,
      'unit_id': unitId,
    };
  }
}
