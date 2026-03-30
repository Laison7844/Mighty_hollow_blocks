import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/customer_screen.dart';
import 'package:flutter_projects/ui/home_screen.dart';
import 'package:flutter_projects/ui/orders/order_screen.dart';
import 'package:flutter_projects/ui/production_screen.dart';
import 'package:flutter_projects/ui/settings.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:go_router/go_router.dart';

class Dashborad extends StatelessWidget {
  const Dashborad({super.key});

  static String path = "/dashboard";
  static const double contentBottomSpacing = 104;

  static final List<_DashboardItem> _items = [
    _DashboardItem(
      label: 'Inventory',
      icon: Icons.dashboard_customize_rounded,
      route: HomeScreen.path,
    ),
    _DashboardItem(
      label: 'Production',
      icon: Icons.precision_manufacturing_rounded,
      route: ProductionScreen.path,
    ),
    _DashboardItem(
      label: 'Orders',
      icon: Icons.receipt_long_rounded,
      route: OrdersScreen.path,
    ),
    _DashboardItem(
      label: 'Customers',
      icon: Icons.groups_2_rounded,
      route: CustomerScreen.path,
    ),
    _DashboardItem(
      label: 'Settings',
      icon: Icons.tune_rounded,
      route: SettingsScreen.path,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedIndex(location);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: ColorUtil.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: ColorUtil.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F2D59),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = index == selectedIndex;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (!isSelected) {
                        context.go(item.route);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? ColorUtil.actionGradient : null,
                        color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : ColorUtil.textSecondary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : ColorUtil.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  int _selectedIndex(String location) {
    final index = _items.indexWhere((item) => location.startsWith(item.route));
    return index >= 0 ? index : 0;
  }
}

class _DashboardItem {
  const _DashboardItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
