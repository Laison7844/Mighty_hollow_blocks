import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_projects/ui/customer_screen.dart';
import 'package:flutter_projects/ui/home_screen.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: HomeScreen.path,
    routes: [
      GoRoute(
        path: HomeScreen.path,
        builder: (context, state) =>  HomeScreen(),
      ),
      GoRoute(
        path: CustomerScreen.path,
        builder: (context, state) => const CustomerScreen(),
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
