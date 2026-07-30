import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projects/model/production_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productionRepositoryProvider = Provider((ref) => ProductionRepository());

final productionStreamProvider = StreamProvider<List<ProductionModel>>((ref) {
  return ref.watch(productionRepositoryProvider).getProductionLogs();
});

class ProductionRepository {
  final CollectionReference _productionCollection = FirebaseFirestore.instance
      .collection('production');

  final DocumentReference _inventoryRef = FirebaseFirestore.instance.collection('metadata').doc('inventory');

  // Add Production Log
  Future<void> addProduction(ProductionModel production) async {
    final docRef = _productionCollection.doc();
    final newProduction = production.copyWith(id: docRef.id);

    final batch = FirebaseFirestore.instance.batch();
    batch.set(docRef, newProduction.toJson());
    batch.set(_inventoryRef, {
      'stock_4_inch': FieldValue.increment(production.fourInch),
      'stock_6_inch': FieldValue.increment(production.sixInch),
      'stock_8_inch': FieldValue.increment(production.eightInch),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  // Update Production Log
  Future<void> updateProduction(ProductionModel production) async {
    if (production.id == null) return;
    
    await FirebaseFirestore.instance.runTransaction((transaction) async {
       final oldDoc = await transaction.get(_productionCollection.doc(production.id));
       if (!oldDoc.exists) return;
       final oldData = oldDoc.data() as Map<String, dynamic>;
       
       final diff4 = production.fourInch - (oldData['fourInch'] as int? ?? 0);
       final diff6 = production.sixInch - (oldData['sixInch'] as int? ?? 0);
       final diff8 = production.eightInch - (oldData['eightInch'] as int? ?? 0);

       transaction.update(_productionCollection.doc(production.id), production.toJson());
       
       if (diff4 != 0 || diff6 != 0 || diff8 != 0) {
           transaction.set(_inventoryRef, {
              'stock_4_inch': FieldValue.increment(diff4),
              'stock_6_inch': FieldValue.increment(diff6),
              'stock_8_inch': FieldValue.increment(diff8),
           }, SetOptions(merge: true));
       }
    });
  }

  // Delete Production Log
  Future<void> deleteProduction(String id) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
       final oldDoc = await transaction.get(_productionCollection.doc(id));
       if (!oldDoc.exists) return;
       final oldData = oldDoc.data() as Map<String, dynamic>;
       
       final diff4 = -(oldData['fourInch'] as int? ?? 0);
       final diff6 = -(oldData['sixInch'] as int? ?? 0);
       final diff8 = -(oldData['eightInch'] as int? ?? 0);

       transaction.delete(_productionCollection.doc(id));
       
       if (diff4 != 0 || diff6 != 0 || diff8 != 0) {
           transaction.set(_inventoryRef, {
              'stock_4_inch': FieldValue.increment(diff4),
              'stock_6_inch': FieldValue.increment(diff6),
              'stock_8_inch': FieldValue.increment(diff8),
           }, SetOptions(merge: true));
       }
    });
  }

  // Get Production Stream
  Stream<List<ProductionModel>> getProductionLogs() {
    return _productionCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ProductionModel.fromSnapshot(doc);
          }).toList();
        });
  }

  Future<List<ProductionModel>> getProductionLogsInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final snapshot = await _productionCollection
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProductionModel.fromSnapshot(doc))
        .toList();
  }

  // Get Today's Production
  Future<int> getTodayProduction() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await _productionCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    int total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['totalProduction'] as num).toInt();
    }
    return total;
  }
}
