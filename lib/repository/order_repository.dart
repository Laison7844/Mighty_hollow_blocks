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

  final DocumentReference _inventoryRef = FirebaseFirestore.instance.collection('metadata').doc('inventory');

  // Add Order
  Future<void> addOrder(OrderModel order) async {
    final docRef = _ordersCollection.doc();
    final newOrder = order.copyWith(id: docRef.id);

    final batch = FirebaseFirestore.instance.batch();
    batch.set(docRef, newOrder.toJson());
    if (!order.isCancelled) {
        batch.set(_inventoryRef, {
        'stock_4_inch': FieldValue.increment(-order.stock4inch),
        'stock_6_inch': FieldValue.increment(-order.stock6inch),
        'stock_8_inch': FieldValue.increment(-order.stock8inch),
        }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Stream<List<OrderModel>> getOrders() {
    return _ordersCollection
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) {
            return OrderModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          }).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Future<List<OrderModel>> getOrdersInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _ordersCollection
        .where('order_date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('order_date', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('order_date', descending: true)
        .get();

    final orders = snapshot.docs.map((doc) {
      return OrderModel.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    }).toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  // Update Payment
  Future<void> updatePayment(
    String orderId,
    int amountPaid, {
    String paymentMode = 'Money in hand',
  }) async {
    final docRef = _ordersCollection.doc(orderId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Order not found!");
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentPaid = data['paid_amount'] as int? ?? 0;
      final currentDue = data['due_amount'] as int? ?? 0;
      
      if (amountPaid > currentDue) {
        throw Exception("Paid amount cannot exceed the due amount!");
      }

      final currentHistory = (data['payment_history'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();

      final newPaid = currentPaid + amountPaid;
      final newDue = currentDue - amountPaid;
      final newHistory = [
        ...currentHistory,
        PaymentEntry(
          amount: amountPaid,
          date: DateTime.now(),
          paymentMode: paymentMode,
        ).toJson(),
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
  Future<void> updateDeliveryStatus(
    String orderId, {
    String? deliveryNotes,
  }) async {
    final docRef = _ordersCollection.doc(orderId);
    final updates = <String, dynamic>{
      'delivery_status': 1, // 1 = Delivered
      'is_delivered': true,
      'delivery_date': DateTime.now().toIso8601String(),
    };
    if (deliveryNotes != null && deliveryNotes.trim().isNotEmpty) {
      updates['delivery_notes'] = deliveryNotes.trim();
    }
    await docRef.update(updates);
  }

  // Update Order
  Future<void> updateOrder(OrderModel order) async {
    if (order.id == null) return;
    
    await FirebaseFirestore.instance.runTransaction((transaction) async {
       final oldDoc = await transaction.get(_ordersCollection.doc(order.id));
       if (!oldDoc.exists) return;
       final oldData = oldDoc.data() as Map<String, dynamic>;
       
       final oldIsCancelled = oldData['is_cancelled'] ?? false;
       final newIsCancelled = order.isCancelled;

       int diff4 = 0, diff6 = 0, diff8 = 0;

       if (!oldIsCancelled && !newIsCancelled) {
           diff4 = (oldData['stock_4_inch'] as int? ?? 0) - order.stock4inch;
           diff6 = (oldData['stock_6_inch'] as int? ?? 0) - order.stock6inch;
           diff8 = (oldData['stock_8_inch'] as int? ?? 0) - order.stock8inch;
       } else if (oldIsCancelled && !newIsCancelled) {
           diff4 = -order.stock4inch;
           diff6 = -order.stock6inch;
           diff8 = -order.stock8inch;
       } else if (!oldIsCancelled && newIsCancelled) {
           diff4 = (oldData['stock_4_inch'] as int? ?? 0);
           diff6 = (oldData['stock_6_inch'] as int? ?? 0);
           diff8 = (oldData['stock_8_inch'] as int? ?? 0);
       }

       transaction.update(_ordersCollection.doc(order.id), order.toJson());
       
       if (diff4 != 0 || diff6 != 0 || diff8 != 0) {
           transaction.set(_inventoryRef, {
              'stock_4_inch': FieldValue.increment(diff4),
              'stock_6_inch': FieldValue.increment(diff6),
              'stock_8_inch': FieldValue.increment(diff8),
           }, SetOptions(merge: true));
       }
    });
  }

  // Delete Order
  Future<void> deleteOrder(String orderId) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
       final oldDoc = await transaction.get(_ordersCollection.doc(orderId));
       if (!oldDoc.exists) return;
       final oldData = oldDoc.data() as Map<String, dynamic>;
       
       final isCancelled = oldData['is_cancelled'] ?? false;

       int diff4 = 0, diff6 = 0, diff8 = 0;
       if (!isCancelled) {
           diff4 = (oldData['stock_4_inch'] as int? ?? 0);
           diff6 = (oldData['stock_6_inch'] as int? ?? 0);
           diff8 = (oldData['stock_8_inch'] as int? ?? 0);
       }

       transaction.delete(_ordersCollection.doc(orderId));
       
       if (diff4 != 0 || diff6 != 0 || diff8 != 0) {
           transaction.set(_inventoryRef, {
              'stock_4_inch': FieldValue.increment(diff4),
              'stock_6_inch': FieldValue.increment(diff6),
              'stock_8_inch': FieldValue.increment(diff8),
           }, SetOptions(merge: true));
       }
    });
  }

  // Cancel Order
  Future<void> cancelOrder(String orderId) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
       final oldDoc = await transaction.get(_ordersCollection.doc(orderId));
       if (!oldDoc.exists) return;
       final oldData = oldDoc.data() as Map<String, dynamic>;
       
       if (oldData['is_cancelled'] == true) return; 

       final diff4 = (oldData['stock_4_inch'] as int? ?? 0);
       final diff6 = (oldData['stock_6_inch'] as int? ?? 0);
       final diff8 = (oldData['stock_8_inch'] as int? ?? 0);

       transaction.update(_ordersCollection.doc(orderId), {'is_cancelled': true});
       
       if (diff4 != 0 || diff6 != 0 || diff8 != 0) {
           transaction.set(_inventoryRef, {
              'stock_4_inch': FieldValue.increment(diff4),
              'stock_6_inch': FieldValue.increment(diff6),
              'stock_8_inch': FieldValue.increment(diff8),
           }, SetOptions(merge: true));
       }
    });
  }
}
