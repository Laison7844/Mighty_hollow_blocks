import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionModel {
  final String? id; // Firestore Document ID
  final DateTime date; // date of production
  final int totalProduction; // total blocks produced
  final int fourInch; // 4-inch blocks
  final int sixInch; // 6-inch blocks
  final int eightInch; // 8-inch blocks
  final String description;

  ProductionModel({
    this.id,
    required this.date,
    required this.totalProduction,
    required this.fourInch,
    required this.sixInch,
    required this.eightInch,
    this.description = '',
  });

  // ------------------------------
  // FROM FIREBASE WRAPPER
  // ------------------------------
  factory ProductionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductionModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      totalProduction: data['totalProduction'] ?? 0,
      fourInch: data['fourInch'] ?? 0,
      sixInch: data['sixInch'] ?? 0,
      eightInch: data['eightInch'] ?? 0,
      description: data['description'] ?? '',
    );
  }

  // ------------------------------
  // FROM JSON (Legacy/Copy support)
  // ------------------------------
  factory ProductionModel.fromJson(Map<String, dynamic> json) {
    return ProductionModel(
      id: json['id'],
      date: (json['date'] as Timestamp).toDate(),
      totalProduction: json['totalProduction'] ?? 0,
      fourInch: json['fourInch'] ?? 0,
      sixInch: json['sixInch'] ?? 0,
      eightInch: json['eightInch'] ?? 0,
      description: json['description'] ?? '',
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
      'description': description,
    };
  }

  // ------------------------------
  // COPY WITH
  // ------------------------------
  ProductionModel copyWith({
    String? id,
    DateTime? date,
    int? totalProduction,
    int? fourInch,
    int? sixInch,
    int? eightInch,
    String? description,
  }) {
    return ProductionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      totalProduction: totalProduction ?? this.totalProduction,
      fourInch: fourInch ?? this.fourInch,
      sixInch: sixInch ?? this.sixInch,
      eightInch: eightInch ?? this.eightInch,
      description: description ?? this.description,
    );
  }
}
