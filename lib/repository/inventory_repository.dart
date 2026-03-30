import 'package:flutter_projects/model/inventory_model.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/repository/production_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider that watches both lists to calculate inventory
final inventoryCalculatedProvider = Provider<AsyncValue<InventoryModel>>((ref) {
  final productionAsync = ref.watch(productionStreamProvider);
  final orderAsync = ref.watch(orderStreamProvider);

  if (productionAsync.isLoading || orderAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (productionAsync.hasError) {
    return AsyncValue.error(
      productionAsync.error!,
      productionAsync.stackTrace!,
    );
  }
  if (orderAsync.hasError) {
    return AsyncValue.error(orderAsync.error!, orderAsync.stackTrace!);
  }

  final productions = productionAsync.value ?? [];
  final orders = orderAsync.value ?? [];

  int totalProduced4 = 0;
  int totalProduced6 = 0;
  int totalProduced8 = 0;

  for (var p in productions) {
    totalProduced4 += p.fourInch;
    totalProduced6 += p.sixInch;
    totalProduced8 += p.eightInch;
  }

  int totalSold4 = 0;
  int totalSold6 = 0;
  int totalSold8 = 0;

  for (var o in orders) {
    // Subtract stock for all orders or only delivered?
    // Assuming all orders reduce stock availability.
    totalSold4 += o.stock4inch;
    totalSold6 += o.stock6inch;
    totalSold8 += o.stock8inch;
  }

  return AsyncValue.data(
    InventoryModel(
      stock4Inch: totalProduced4 - totalSold4,
      stock6Inch: totalProduced6 - totalSold6,
      stock8Inch: totalProduced8 - totalSold8,
    ),
  );
});
