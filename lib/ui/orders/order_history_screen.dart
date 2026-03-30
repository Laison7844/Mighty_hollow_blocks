import 'package:flutter/material.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/order_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  static String path = "/order-history";

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  // Filter Logic
  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    return orders.where((order) {
      bool matchesSearch =
          order.name.toLowerCase().contains(_searchQuery) ||
          order.orderId.toLowerCase().contains(_searchQuery);

      bool matchesDate =
          _selectedDate == null ||
          (order.orderDate.year == _selectedDate!.year &&
              order.orderDate.month == _selectedDate!.month &&
              order.orderDate.day == _selectedDate!.day);

      return matchesSearch && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(title: "Order History"),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search Name or ID...",
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _selectedDate != null
                            ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: _pickDate,
                        icon: Icon(
                          Icons.calendar_today,
                          color: _selectedDate != null
                              ? const Color(0xFF2563EB)
                              : Colors.grey,
                        ),
                      ),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        onPressed: _clearDate,
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                  ],
                ),
                if (_selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "Filtering by date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filtered = _filterOrders(orders);

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      orders.isEmpty ? "No orders yet" : "No matching orders",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: filtered
                        .map((order) => OrderListItem(order: order))
                        .toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }
}
