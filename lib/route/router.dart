import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/dashborad.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_projects/ui/splash_screen.dart';
import 'package:flutter_projects/ui/home_screen.dart';
import 'package:flutter_projects/ui/customer_screen.dart';
import 'package:flutter_projects/ui/production_screen.dart';
import 'package:flutter_projects/ui/order_screen.dart';
import 'package:flutter_projects/ui/settings.dart';
import 'package:flutter_projects/ui/add_stocks.dart';



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
            bottomNavigationBar: Dashborad(),
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
        path: AddStocks.path,
        builder: (context, state) => const AddStocks(),
      ),
    ],
  );
});
