import 'package:flutter/material.dart';
import 'package:flutter_projects/core/constants/constants.dart';
import 'package:flutter_projects/repository/inventory_repository.dart';
import 'package:flutter_projects/ui/add_sections/add_stocks.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/button.dart';
import 'package:flutter_projects/ui/dashborad.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static String path = "/home_screen";

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryCalculatedProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Inventory',
        subtitle: 'Live stock position across all block sizes.',
      ),
      body: inventoryAsync.when(
        data: (inventory) {
          final stocks = [
            inventory.stock4Inch,
            inventory.stock6Inch,
            inventory.stock8Inch,
          ];
          final totalUnits = stocks.fold(0, (sum, units) => sum + units);
          final lowStockCount = stocks.where((units) => units < 250).length;

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
                _buildOverviewCard(
                  totalUnits: totalUnits,
                  lowStockCount: lowStockCount,
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Stock overview',
                  subtitle: 'Tap any card to add fresh stock for that block.',
                ),
                const SizedBox(height: 14),
                _buildInventoryCard(
                  title: "4 Inch",
                  type: 4,
                  units: inventory.stock4Inch,
                ),
                _buildInventoryCard(
                  title: "6 Inch",
                  type: 6,
                  units: inventory.stock6Inch,
                ),
                _buildInventoryCard(
                  title: "8 Inch",
                  type: 8,
                  units: inventory.stock8Inch,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  icon: const Icon(Icons.sync_rounded),
                  name: "Refresh dashboard",
                  onTap: () {
                    ref.invalidate(inventoryCalculatedProvider);
                  },
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
              "Error loading inventory: $err",
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorUtil.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required int totalUnits,
    required int lowStockCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ColorUtil.heroGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F2D59),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Current stock status',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$totalUnits',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'units available across all active block sizes',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFD7E6FF),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Low stock types',
                  value: '$lowStockCount',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _HeroMetric(label: 'Tracked sizes', value: '3'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard({
    required String title,
    required int type,
    required int units,
  }) {
    final color = ColorUtil.inventoryColor(type);
    final tint = ColorUtil.inventoryTint(type);
    final name = switch (type) {
      4 => Constants.type4,
      6 => Constants.type6,
      _ => Constants.type8,
    };
    final statusLabel = units < 250
        ? 'Needs restock'
        : units < 500
        ? 'Watch level'
        : 'Healthy';
    final statusColor = units < 250
        ? ColorUtil.danger
        : units < 500
        ? ColorUtil.accent
        : ColorUtil.darkGreen;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AddStocks(blockName: title, type: type),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorUtil.surface, tint],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: ColorUtil.border),
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.view_in_ar_rounded, color: color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            name,
                            style: const TextStyle(
                              color: ColorUtil.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '$units',
                  style: const TextStyle(
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: ColorUtil.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ready units',
                  style: TextStyle(
                    fontSize: 14,
                    color: ColorUtil.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _InfoPill(
                        icon: Icons.stacked_bar_chart_rounded,
                        label: units < 250 ? 'Below target' : 'Stable supply',
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoPill(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Add stock',
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ColorUtil.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
