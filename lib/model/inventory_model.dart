class InventoryModel {
  int? type;
  int? totalCount;

  InventoryModel({
    this.type,
    this.totalCount,
  });

  // From JSON (Firestore / API → Model)
  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      type: json['type'] as int?,
      totalCount: json['totalCount'] as int?,
    );
  }

  // To JSON (Model → Firestore / API)
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'totalCount': totalCount,
    };
  }

  // For updating values immutably
  InventoryModel copyWith({
    int? type,
    int? totalCount,
  }) {
    return InventoryModel(
      type: type ?? this.type,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  String toString() {
    return 'InventoryModel(type: $type, totalCount: $totalCount)';
  }
}
