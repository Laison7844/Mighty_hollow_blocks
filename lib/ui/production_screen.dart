import 'package:flutter/material.dart';
import 'package:flutter_projects/model/production_model.dart';
import 'package:flutter_projects/repository/production_repository.dart';
import 'package:flutter_projects/ui/add_sections/add_production.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/button.dart';
import 'package:flutter_projects/ui/customs/production_list_item.dart';
import 'package:flutter_projects/ui/dashborad.dart';
import 'package:flutter_projects/ui/production_history_screen.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ProductionScreen extends ConsumerStatefulWidget {
  const ProductionScreen({super.key});

  static String path = "/production-screen";

  @override
  ConsumerState<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends ConsumerState<ProductionScreen> {
  String _formatProductionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final given = DateTime(date.year, date.month, date.day);

    if (given == today) {
      return "Today's total";
    }
    if (given == today.subtract(const Duration(days: 1))) {
      return "Yesterday's total";
    }

    return DateFormat("MMM dd, yyyy").format(date);
  }

  int _todayTotal(List<ProductionModel> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return logs
        .where(
          (log) =>
              log.date.year == today.year &&
              log.date.month == today.month &&
              log.date.day == today.day,
        )
        .fold(0, (sum, log) => sum + log.totalProduction);
  }

  @override
  Widget build(BuildContext context) {
    final productionAsync = ref.watch(productionStreamProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Production",
        subtitle: "Monitor output and log every production batch cleanly.",
      ),
      body: productionAsync.when(
        data: (logs) {
          final recentLogs = logs.take(3).toList();
          final totalProduced = logs.fold<int>(
            0,
            (sum, log) => sum + log.totalProduction,
          );
          final todayTotal = _todayTotal(logs);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              Dashborad.contentBottomSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductionSummaryCard(
                  label: _formatProductionDate(DateTime.now()),
                  todayTotal: todayTotal,
                  lifetimeTotal: totalProduced,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  icon: const Icon(Icons.add_chart_rounded),
                  name: "Record production",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddProduction(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: _SectionHeader(
                        title: "Recent logs",
                        subtitle:
                            "Latest production entries available in the system.",
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProductionHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text("View all"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recentLogs.isEmpty)
                  const _EmptyState(message: "No production logs recorded yet")
                else
                  ...recentLogs.map(
                    (log) => ProductionListItem(production: log),
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
              "Error loading production logs: $err",
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorUtil.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductionSummaryCard extends StatelessWidget {
  const _ProductionSummaryCard({
    required this.label,
    required this.todayTotal,
    required this.lifetimeTotal,
  });

  final String label;
  final int todayTotal;
  final int lifetimeTotal;

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
            label,
            style: const TextStyle(
              color: Color(0xFFD7E6FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "$todayTotal blocks",
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "logged for the current day",
            style: TextStyle(color: Color(0xFFD7E6FF)),
          ),
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
                  Icons.factory_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Lifetime production: $lifetimeTotal blocks",
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
            Icons.inventory_2_outlined,
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
