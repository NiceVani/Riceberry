class FinancialTransactionModel {
  final int id;
  final int? categoryId;
  final int? purchaseId;
  final int? saleId;
  final DateTime? transactionDate;
  final double amount;
  final String? description;

  FinancialTransactionModel({
    required this.id,
    this.categoryId,
    this.purchaseId,
    this.saleId,
    this.transactionDate,
    required this.amount,
    this.description,
  });

  factory FinancialTransactionModel.fromJson(Map<String, dynamic> json) {
    return FinancialTransactionModel(
      id: json['transaction_id'] ?? 0,
      categoryId: json['category_id'],
      purchaseId: json['purchase_id'],
      saleId: json['sale_id'],
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'purchase_id': purchaseId,
      'sale_id': saleId,
      'transaction_date': transactionDate?.toIso8601String(),
      'amount': amount,
      'description': description,
    };
  }
}
