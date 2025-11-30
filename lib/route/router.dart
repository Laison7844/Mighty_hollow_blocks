import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/add_stocks.dart';
import 'package:flutter_projects/ui/order_screen.dart';
import 'package:flutter_projects/ui/production_screen.dart';
import 'package:flutter_projects/ui/settings.dart';
import 'package:flutter_projects/ui/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_projects/ui/customer_screen.dart';
import 'package:flutter_projects/ui/home_screen.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.path,
    routes: [
       GoRoute(
        path: SplashScreen.path,
        builder: (context, state) =>  SplashScreen(),
      ),
      GoRoute(
        path: HomeScreen.path,
        builder: (context, state) =>  HomeScreen(),
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
        path: AddStocks.path,
        builder: (context, state) => const AddStocks(),
      ), 
        GoRoute(
        path:SettingsScreen.path,
        builder: (context, state) => const SettingsScreen(),
      ),

      // === Example dynamic route ===
      // GoRoute(
      //   path: '/order/:id',
      //   builder: (context, state) {
      //     final id = state.params['id']!;
      //     return OrderDetailScreen(orderId: id);
      //   },
      // ),
    ],
  );
});
