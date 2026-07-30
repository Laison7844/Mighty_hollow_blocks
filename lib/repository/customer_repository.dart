import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projects/model/customer_model.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerRepositoryProvider = Provider((ref) => CustomerRepository());

final rawCustomerStreamProvider = StreamProvider<List<CustomerModel>>((ref) {
  return ref.watch(customerRepositoryProvider).getCustomers();
});

final customerStreamProvider = Provider<AsyncValue<List<CustomerModel>>>((ref) {
  final manualCustomersAsync = ref.watch(rawCustomerStreamProvider);
  final ordersAsync = ref.watch(orderStreamProvider);

  if (manualCustomersAsync.isLoading || ordersAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (manualCustomersAsync.hasError) {
    return AsyncValue.error(
      manualCustomersAsync.error!,
      manualCustomersAsync.stackTrace!,
    );
  }

  if (ordersAsync.hasError) {
    return AsyncValue.error(ordersAsync.error!, ordersAsync.stackTrace!);
  }

  final customers = buildCustomerProfiles(
    manualCustomersAsync.value ?? const [],
    ordersAsync.value ?? const [],
  );

  return AsyncValue.data(customers);
});

class CustomerRepository {
  final CollectionReference _customersCollection = FirebaseFirestore.instance
      .collection('customers');

  // Add Customer
  Future<void> addCustomer(CustomerModel customer) async {
    await _customersCollection.add(customer.toJson());
  }

  // Get Customers Stream
  Stream<List<CustomerModel>> getCustomers() {
    return _customersCollection
        .orderBy('registrationDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CustomerModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          }).toList();
        });
  }

  Future<List<CustomerModel>> getCustomersOnce() async {
    final snapshot = await _customersCollection
        .orderBy('registrationDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return CustomerModel.fromJson(
        doc.data() as Map<String, dynamic>,
        id: doc.id,
      );
    }).toList();
  }
}

List<CustomerModel> buildCustomerProfiles(
  List<CustomerModel> manualCustomers,
  List<OrderModel> orders,
) {
  final customerMap = <String, CustomerModel>{};

  for (final customer in manualCustomers) {
    customerMap[_customerKey(customer.companyName, customer.phoneNumber)] =
        customer;
  }

  // Sort orders chronologically ascending so when iterating, newer orders update latest info
  final sortedOrders = [...orders]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  for (final order in sortedOrders) {
    final nameKey = order.name.trim().toLowerCase();
    final exactKey = _customerKey(order.name, order.customerMobile);
    final fallbackKey = _customerKey(order.name, '');

    CustomerModel? existing = customerMap[exactKey] ?? customerMap[fallbackKey];
    if (existing == null) {
      for (final c in customerMap.values) {
        if (c.companyName.trim().toLowerCase() == nameKey ||
            (order.customerMobile.isNotEmpty && c.phoneNumber == order.customerMobile)) {
          existing = c;
          break;
        }
      }
    }

    final keyToUse = existing != null
        ? _customerKey(existing.companyName, existing.phoneNumber)
        : exactKey;

    final existingOrders = existing?.orders ?? const <OrderModel>[];
    final mergedOrders = [...existingOrders, order]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final addressToUse = (existing?.address.isNotEmpty ?? false)
        ? existing!.address
        : (order.address.isNotEmpty ? order.address : '');

    customerMap[keyToUse] = CustomerModel(
      id: existing?.id,
      companyName: existing?.companyName.isNotEmpty ?? false ? existing!.companyName : order.name,
      phoneNumber: order.customerMobile.isNotEmpty
          ? order.customerMobile
          : (existing?.phoneNumber ?? ''),
      address: addressToUse,
      description: existing?.description ?? '',
      totalSales: (existing?.totalSales ?? 0) + order.orderValue,
      totalPaid: (existing?.totalPaid ?? 0) + order.paidAmount,
      totalDue: (existing?.totalDue ?? 0) + order.dueAmount,
      orderCount: mergedOrders.length,
      registrationDate: _earlierDate(
        existing?.registrationDate,
        order.createdAt,
      ),
      lastOrderDate: _laterDate(existing?.lastOrderDate, order.createdAt),
      orders: mergedOrders,
    );

    if (keyToUse != exactKey && customerMap.containsKey(exactKey)) {
      customerMap.remove(exactKey);
    }
    if (keyToUse != fallbackKey && customerMap.containsKey(fallbackKey)) {
      customerMap.remove(fallbackKey);
    }
  }

  final customers = customerMap.values.toList()
    ..sort((a, b) {
      final left = a.orders.isNotEmpty
          ? a.orders.first.createdAt
          : (a.lastOrderDate ?? a.registrationDate);
      final right = b.orders.isNotEmpty
          ? b.orders.first.createdAt
          : (b.lastOrderDate ?? b.registrationDate);
      return right.compareTo(left);
    });

  return customers;
}

String _customerKey(String name, String phone) {
  final normalizedName = name.trim().toLowerCase();
  final normalizedPhone = phone.replaceAll(RegExp(r'\s+'), '');
  return '$normalizedName|$normalizedPhone';
}

DateTime _earlierDate(DateTime? left, DateTime right) {
  if (left == null || right.isBefore(left)) {
    return right;
  }
  return left;
}

DateTime _laterDate(DateTime? left, DateTime right) {
  if (left == null || right.isAfter(left)) {
    return right;
  }
  return left;
}
