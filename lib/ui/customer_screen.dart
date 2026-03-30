import 'package:flutter/material.dart';
import 'package:flutter_projects/repository/customer_repository.dart';
import 'package:flutter_projects/ui/add_sections/add_customer.dart';
import 'package:flutter_projects/ui/dashborad.dart';
import 'package:flutter_projects/ui/customer_detail_screen.dart';
import 'package:flutter_projects/ui/customer_history_screen.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/button.dart';
import 'package:flutter_projects/ui/customs/customer_list_item.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  static String path = "/customer-screen";

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerStreamProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Customers",
        subtitle: "Keep client records and lifetime sales in one place.",
      ),
      body: customerAsync.when(
        data: (customers) {
          final recentCustomers = customers.take(3).toList();
          final totalSales = customers.fold<int>(
            0,
            (sum, customer) => sum + customer.totalSales,
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
                _SummaryCard(
                  title: 'Customer book',
                  value: '${customers.length}',
                  description: 'registered companies',
                  secondaryLabel: 'Lifetime sales',
                  secondaryValue: '₹ $totalSales',
                ),
                const SizedBox(height: 16),
                CustomButton(
                  name: "Register New Customer",
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  onTap: () {
                    context.push(AddCustomer.path);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: _SectionHeader(
                        title: "Recent customers",
                        subtitle: "Latest registrations and account activity.",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomerHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text("View all"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentCustomers.isEmpty)
                  const _EmptyState(message: "No customers registered yet")
                else
                  ...recentCustomers.map(
                    (customer) => CustomerListItem(
                      customer: customer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CustomerDetailScreen(customer: customer),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Error loading customers: $err",
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorUtil.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.description,
    required this.secondaryLabel,
    required this.secondaryValue,
  });

  final String title;
  final String value;
  final String description;
  final String secondaryLabel;
  final String secondaryValue;

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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD7E6FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Color(0xFFD7E6FF))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$secondaryLabel: $secondaryValue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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
            Icons.groups_2_outlined,
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
