class InventoryModel {
  final int stock4Inch;
  final int stock6Inch;
  final int stock8Inch;

  InventoryModel({
    required this.stock4Inch,
    required this.stock6Inch,
    required this.stock8Inch,
  });

  @override
  String toString() {
    return 'InventoryModel(4": $stock4Inch, 6": $stock6Inch, 8": $stock8Inch)';
  }
}
