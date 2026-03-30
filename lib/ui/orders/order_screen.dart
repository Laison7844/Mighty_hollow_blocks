import 'package:flutter/material.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/ui/add_sections/add_order.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/button.dart';
import 'package:flutter_projects/ui/dashborad.dart';
import 'package:flutter_projects/ui/customs/order_list_item.dart';
import 'package:flutter_projects/ui/orders/order_history_screen.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  static String path = "/orders-screen";

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderStreamProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Orders",
        subtitle: "Track open orders, collections and delivery progress.",
      ),
      body: ordersAsync.when(
        data: (orders) {
          final recentOrders = orders.take(3).toList();
          final pendingOrders = orders
              .where((order) => !order.isDelivered)
              .length;
          final pendingValue = orders.fold<int>(
            0,
            (sum, order) => sum + order.dueAmount,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              Dashborad.contentBottomSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrdersSummaryCard(
                  totalOrders: orders.length,
                  pendingOrders: pendingOrders,
                  pendingValue: pendingValue,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  name: "Create new order",
                  icon: const Icon(Icons.playlist_add_circle_rounded),
                  onTap: () {
                    context.push(AddOrder.path);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: _SectionHeader(
                        title: "Recent orders",
                        subtitle: "Latest client orders and payment movement.",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text("View all"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (recentOrders.isEmpty)
                  const _EmptyState(message: "No orders created yet")
                else
                  ...recentOrders.map((order) => OrderListItem(order: order)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Error loading orders: $err",
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorUtil.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrdersSummaryCard extends StatelessWidget {
  const _OrdersSummaryCard({
    required this.totalOrders,
    required this.pendingOrders,
    required this.pendingValue,
  });

  final int totalOrders;
  final int pendingOrders;
  final int pendingValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ColorUtil.heroGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Orders pipeline",
            style: TextStyle(
              color: Color(0xFFD7E6FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$totalOrders active orders",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: "Pending delivery",
                  value: "$pendingOrders",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: "Due collection",
                  value: "₹ $pendingValue",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD7E6FF),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: ColorUtil.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: ColorUtil.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: ColorUtil.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: ColorUtil.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
