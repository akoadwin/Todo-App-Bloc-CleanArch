class UpdateGroceryModel {
  final String id;
  final String productName;
  final int quantity;
  final double price;
  final double total;

  UpdateGroceryModel({
    required this.total,
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}
