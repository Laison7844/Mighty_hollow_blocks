class PaymentEntry {
  final int amount;
  final DateTime date;

  const PaymentEntry({required this.amount, required this.date});

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    return PaymentEntry(
      amount: json['amount']?.toInt() ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'date': date.toIso8601String()};
  }
}

class OrderModel {
  final String? id; // Firestore Document ID
  final String name;
  final String customerMobile;
  final String orderId;
  final int paidAmount;
  final int dueAmount;
  final int paymentStatus;
  final int deliveryStatus;
  final DateTime orderDate;
  final String deliveryDate;
  final int orderValue;
  final bool isDelivered;
  final bool isPaid;
  final String description;

  // --- NEW: Separate Stock Parameters ---
  final int stock4inch;
  final int stock6inch;
  final int stock8inch;
  final List<PaymentEntry> paymentHistory;

  OrderModel({
    this.id,
    required this.name,
    required this.customerMobile,
    required this.orderId,
    required this.paidAmount,
    required this.dueAmount,
    required this.paymentStatus,
    required this.deliveryStatus,
    required this.orderDate,
    required this.deliveryDate,
    required this.orderValue,
    this.description = '',
    required this.stock4inch,
    required this.stock6inch,
    required this.stock8inch,
    this.paymentHistory = const [],
    this.isDelivered = false,
    this.isPaid = false,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return OrderModel(
      id: id,
      name: json['name'] ?? '',
      customerMobile: json['customer_mobile'] ?? '',
      orderId: json['order_id'] ?? '',
      paidAmount: json['paid_amount']?.toInt() ?? 0,
      dueAmount: json['due_amount']?.toInt() ?? 0,
      paymentStatus: json['payment_status']?.toInt() ?? 2,
      deliveryStatus: json['delivery_status']?.toInt() ?? 0,
      orderDate: json['order_date'] != null
          ? DateTime.parse(json['order_date'])
          : DateTime.now(),
      deliveryDate: json['delivery_date'] ?? '',
      orderValue: json['order_value']?.toInt() ?? 0,
      description: json['description'] ?? '',
      // --- Parsing separate stocks ---
      stock4inch: json['stock_4_inch']?.toInt() ?? 0,
      stock6inch: json['stock_6_inch']?.toInt() ?? 0,
      stock8inch: json['stock_8_inch']?.toInt() ?? 0,
      paymentHistory: (json['payment_history'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (entry) => PaymentEntry.fromJson(Map<String, dynamic>.from(entry)),
          )
          .toList(),
      isDelivered: json['is_delivered'] ?? false,
      isPaid: json['is_paid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'customer_mobile': customerMobile,
      'order_id': orderId,
      'paid_amount': paidAmount,
      'due_amount': dueAmount,
      'payment_status': paymentStatus,
      'delivery_status': deliveryStatus,
      'order_date': orderDate.toIso8601String(),
      'delivery_date': deliveryDate,
      'order_value': orderValue,
      'description': description,
      'stock_4_inch': stock4inch,
      'stock_6_inch': stock6inch,
      'stock_8_inch': stock8inch,
      'payment_history': paymentHistory.map((entry) => entry.toJson()).toList(),
      'is_delivered': isDelivered,
      'is_paid': isPaid,
    };
  }

  int get totalQuantity => stock4inch + stock6inch + stock8inch;

  DateTime? get deliveryDateValue => DateTime.tryParse(deliveryDate);

  List<String> get stockParts {
    final parts = <String>[];
    if (stock4inch > 0) {
      parts.add('4": $stock4inch');
    }
    if (stock6inch > 0) {
      parts.add('6": $stock6inch');
    }
    if (stock8inch > 0) {
      parts.add('8": $stock8inch');
    }
    return parts;
  }

  OrderModel copyWith({
    String? id,
    String? name,
    String? customerMobile,
    String? orderId,
    int? paidAmount,
    int? dueAmount,
    int? paymentStatus,
    int? deliveryStatus,
    DateTime? orderDate,
    String? deliveryDate,
    int? orderValue,
    String? description,
    int? stock4inch,
    int? stock6inch,
    int? stock8inch,
    List<PaymentEntry>? paymentHistory,
    bool? isDelivered,
    bool? isPaid,
  }) {
    return OrderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      customerMobile: customerMobile ?? this.customerMobile,
      orderId: orderId ?? this.orderId,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      orderValue: orderValue ?? this.orderValue,
      description: description ?? this.description,
      stock4inch: stock4inch ?? this.stock4inch,
      stock6inch: stock6inch ?? this.stock6inch,
      stock8inch: stock8inch ?? this.stock8inch,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      isDelivered: isDelivered ?? this.isDelivered,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
