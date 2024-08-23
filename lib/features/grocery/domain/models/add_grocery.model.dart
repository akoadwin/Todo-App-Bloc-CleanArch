class AddGroceryModel {
  final String productName;
  final int quantity;
  final double price;
  final String? titleId;
  double? total;

  AddGroceryModel(
      {required this.productName,
      required this.quantity,
      required this.price,
      this.total,
      this.titleId});
}
