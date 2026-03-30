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

  // Add Production Log
  Future<void> addProduction(ProductionModel production) async {
    await _productionCollection.add(production.toJson());
  }

  // Update Production Log
  Future<void> updateProduction(ProductionModel production) async {
    if (production.id == null) return;
    await _productionCollection.doc(production.id).update(production.toJson());
  }

  // Delete Production Log
  Future<void> deleteProduction(String id) async {
    await _productionCollection.doc(id).delete();
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
