import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projects/model/order_model.dart';

class CustomerModel {
  final String? id;
  final String companyName;
  final String phoneNumber;
  final String address;
  final String description;
  final int totalSales;
  final int totalPaid;
  final int totalDue;
  final int orderCount;
  final DateTime registrationDate; // Added for search by date
  final DateTime? lastOrderDate;
  final List<OrderModel> orders;

  CustomerModel({
    this.id,
    required this.companyName,
    required this.phoneNumber,
    required this.address,
    this.description = '',
    required this.totalSales,
    this.totalPaid = 0,
    this.totalDue = 0,
    this.orderCount = 0,
    required this.registrationDate,
    this.lastOrderDate,
    this.orders = const [],
  });
  // Factory for Firestore
  factory CustomerModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return CustomerModel(
      id: id,
      companyName: json['companyName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      totalSales: json['totalSales'] ?? 0,
      registrationDate: json['registrationDate'] != null
          ? (json['registrationDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'address': address,
      'description': description,
      'totalSales': totalSales,
      'registrationDate': registrationDate,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? companyName,
    String? phoneNumber,
    String? address,
    String? description,
    int? totalSales,
    int? totalPaid,
    int? totalDue,
    int? orderCount,
    DateTime? registrationDate,
    DateTime? lastOrderDate,
    List<OrderModel>? orders,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      totalSales: totalSales ?? this.totalSales,
      totalPaid: totalPaid ?? this.totalPaid,
      totalDue: totalDue ?? this.totalDue,
      orderCount: orderCount ?? this.orderCount,
      registrationDate: registrationDate ?? this.registrationDate,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      orders: orders ?? this.orders,
    );
  }
}
