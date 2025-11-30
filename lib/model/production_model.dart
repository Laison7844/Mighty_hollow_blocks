import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionModel {
  final DateTime date;       // date of production
  final int totalProduction; // total blocks produced
  final int fourInch;        // 4-inch blocks
  final int sixInch;         // 6-inch blocks
  final int eightInch;       // 8-inch blocks

  ProductionModel({
    required this.date,
    required this.totalProduction,
    required this.fourInch,
    required this.sixInch,
    required this.eightInch,
  });

  // ------------------------------
  // FROM FIREBASE DOCUMENT
  // ------------------------------
  factory ProductionModel.fromJson(Map<String, dynamic> json) {
    return ProductionModel(
      date: (json['date'] as Timestamp).toDate(),
      totalProduction: json['totalProduction'] ?? 0,
      fourInch: json['fourInch'] ?? 0,
      sixInch: json['sixInch'] ?? 0,
      eightInch: json['eightInch'] ?? 0,
    );
  }

  // ------------------------------
  // TO FIREBASE DOCUMENT
  // ------------------------------
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'totalProduction': totalProduction,
      'fourInch': fourInch,
      'sixInch': sixInch,
      'eightInch': eightInch,
    };
  }

  // ------------------------------
  // COPY WITH (optional update)
  // ------------------------------
  ProductionModel copyWith({
    DateTime? date,
    int? totalProduction,
    int? fourInch,
    int? sixInch,
    int? eightInch,
  }) {
    return ProductionModel(
      date: date ?? this.date,
      totalProduction: totalProduction ?? this.totalProduction,
      fourInch: fourInch ?? this.fourInch,
      sixInch: sixInch ?? this.sixInch,
      eightInch: eightInch ?? this.eightInch,
    );
  }
}
