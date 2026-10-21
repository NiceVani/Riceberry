class SupplierModel {
  final int id;
  final String name;
  final String? phoneNumber;
  final String? address;

  SupplierModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.address,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['supplier_id'] ?? 0,
      name: json['supplier_name'] ?? '',
      phoneNumber: json['phone_number'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_name': name,
      'phone_number': phoneNumber,
      'address': address,
    };
  }
}
