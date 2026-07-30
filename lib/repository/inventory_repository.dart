import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projects/model/inventory_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryRepositoryProvider = Provider((ref) => InventoryRepository());

final inventoryCalculatedProvider = StreamProvider<InventoryModel>((ref) {
  return ref.watch(inventoryRepositoryProvider).getInventoryStream();
});

class InventoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<InventoryModel> getInventoryStream() {
    return _firestore.collection('metadata').doc('inventory').snapshots().map((doc) {
      if (!doc.exists) {
        return InventoryModel(stock4Inch: 0, stock6Inch: 0, stock8Inch: 0);
      }
      final data = doc.data()!;
      return InventoryModel(
        stock4Inch: data['stock_4_inch'] ?? 0,
        stock6Inch: data['stock_6_inch'] ?? 0,
        stock8Inch: data['stock_8_inch'] ?? 0,
      );
    });
  }

  Future<void> recalculateInventory() async {
    final prodSnapshot = await _firestore.collection('production').get();
    int prod4 = 0, prod6 = 0, prod8 = 0;
    for (var doc in prodSnapshot.docs) {
      final data = doc.data();
      prod4 += (data['fourInch'] as int? ?? 0);
      prod6 += (data['sixInch'] as int? ?? 0);
      prod8 += (data['eightInch'] as int? ?? 0);
    }

    final orderSnapshot = await _firestore.collection('orders').get();
    int ord4 = 0, ord6 = 0, ord8 = 0;
    for (var doc in orderSnapshot.docs) {
      final data = doc.data();
      if (!(data['is_cancelled'] ?? false)) {
        ord4 += (data['stock_4_inch'] as int? ?? 0);
        ord6 += (data['stock_6_inch'] as int? ?? 0);
        ord8 += (data['stock_8_inch'] as int? ?? 0);
      }
    }

    await _firestore.collection('metadata').doc('inventory').set({
      'stock_4_inch': prod4 - ord4,
      'stock_6_inch': prod6 - ord6,
      'stock_8_inch': prod8 - ord8,
    });
  }
}
