class SettingsModel {
  final double price4Inch;
  final double price6Inch;
  final double price8Inch;

  SettingsModel({
    required this.price4Inch,
    required this.price6Inch,
    required this.price8Inch,
  });

  Map<String, dynamic> toJson() {
    return {
      'price_4_inch': price4Inch,
      'price_6_inch': price6Inch,
      'price_8_inch': price8Inch,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      price4Inch: (json['price_4_inch'] ?? 0).toDouble(),
      price6Inch: (json['price_6_inch'] ?? 0).toDouble(),
      price8Inch: (json['price_8_inch'] ?? 0).toDouble(),
    );
  }

  // Default settings
  factory SettingsModel.empty() {
    return SettingsModel(price4Inch: 0.0, price6Inch: 0.0, price8Inch: 0.0);
  }
}
