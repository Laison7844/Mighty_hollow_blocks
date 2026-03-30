import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/add_sections/add_customer.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/ui/dashborad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_projects/ui/splash_screen.dart';
import 'package:flutter_projects/ui/home_screen.dart';
import 'package:flutter_projects/ui/customer_screen.dart';
import 'package:flutter_projects/ui/production_screen.dart';
import 'package:flutter_projects/ui/orders/order_screen.dart';
import 'package:flutter_projects/ui/settings.dart';
import 'package:flutter_projects/ui/add_sections/add_order.dart';
import 'package:flutter_projects/util/color_util.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.path,
    routes: [
      GoRoute(
        path: SplashScreen.path,
        builder: (context, state) => SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: const Dashborad(),
            backgroundColor: ColorUtil.background,
          );
        },
        routes: [
          GoRoute(
            path: HomeScreen.path,
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: CustomerScreen.path,
            builder: (context, state) => const CustomerScreen(),
          ),
          GoRoute(
            path: ProductionScreen.path,
            builder: (context, state) => const ProductionScreen(),
          ),
          GoRoute(
            path: OrdersScreen.path,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: SettingsScreen.path,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AddCustomer.path,
        builder: (context, state) => const AddCustomer(),
      ),
      GoRoute(
        path: AddOrder.path,
        builder: (context, state) {
          final orderToEdit = state.extra as OrderModel?;
          return AddOrder(orderToEdit: orderToEdit);
        },
      ),
    ],
  );
});
