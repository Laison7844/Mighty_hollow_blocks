import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository());

final orderStreamProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});

class OrderRepository {
  final CollectionReference _ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  // Add Order
  Future<void> addOrder(OrderModel order) async {
    await _ordersCollection.add(order.toJson());
  }

  // Get Orders Stream
  Stream<List<OrderModel>> getOrders() {
    return _ordersCollection
        .orderBy('order_date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          }).toList();
        });
  }

  // Update Payment
  Future<void> updatePayment(String orderId, int amountPaid) async {
    final docRef = _ordersCollection.doc(orderId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Order not found!");
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentPaid = data['paid_amount'] as int? ?? 0;
      final currentDue = data['due_amount'] as int? ?? 0;
      final currentHistory = (data['payment_history'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();

      final newPaid = currentPaid + amountPaid;
      final newDue = currentDue - amountPaid;
      final newHistory = [
        ...currentHistory,
        PaymentEntry(amount: amountPaid, date: DateTime.now()).toJson(),
      ];

      // Determine Payment Status
      // 0: Pending, 1: Paid, 2: Advance Paid
      int newStatus = 0;
      if (newDue <= 0) {
        newStatus = 1; // Paid
      } else if (newPaid > 0) {
        newStatus = 2; // Advance Paid
      } else {
        newStatus = 0; // Pending
      }

      transaction.update(docRef, {
        'paid_amount': newPaid,
        'due_amount': newDue,
        'payment_status': newStatus,
        'payment_history': newHistory,
        'is_paid': newStatus == 1,
      });
    });
  }

  // Update Delivery Status
  Future<void> updateDeliveryStatus(String orderId) async {
    final docRef = _ordersCollection.doc(orderId);
    await docRef.update({
      'delivery_status': 1, // 1 = Delivered
      'is_delivered': true,
      'delivery_date': DateTime.now().toIso8601String(),
    });
  }

  // Update Order
  Future<void> updateOrder(OrderModel order) async {
    if (order.id == null) return;
    await _ordersCollection.doc(order.id).update(order.toJson());
  }

  // Delete Order
  Future<void> deleteOrder(String orderId) async {
    await _ordersCollection.doc(orderId).delete();
  }
}
