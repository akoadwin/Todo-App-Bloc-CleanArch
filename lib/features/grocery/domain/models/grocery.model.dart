class GroceryItemModel {
  final String id;
  final String productName;
  final int quantity;
  final double price;
  final double? total;
  final String? titleId;

  GroceryItemModel(
      {required this.id,
      required this.productName,
      required this.quantity,
      required this.price,
      this.total,
      this.titleId});

  factory GroceryItemModel.fromJson(Map<String, dynamic> json) {
    return GroceryItemModel(
      id: json['id'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'],
      total: json['total'],
      titleId: json['titleId'],
    );
  }
}
