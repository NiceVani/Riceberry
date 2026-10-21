class CategoryModel {
  final int id;
  final String name;
  final String? transactionType; // อนุญาตให้เป็น null ได้เผื่อไม่มีข้อมูล

  CategoryModel({required this.id, required this.name, this.transactionType});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['category_id'] ?? 0,
      name: json['category_name'] ?? '',
      transactionType: json['transaction_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'category_name': name, 'transaction_type': transactionType};
  }
}
