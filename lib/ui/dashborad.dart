import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/customer_screen.dart';
import 'package:flutter_projects/ui/home_screen.dart';
import 'package:flutter_projects/ui/order_screen.dart';
import 'package:flutter_projects/ui/production_screen.dart';
import 'package:flutter_projects/ui/settings.dart';
import 'package:go_router/go_router.dart';

class Dashborad extends StatefulWidget {
  const Dashborad({super.key});

  static String path = "/dashboard";
  @override
  State<Dashborad> createState() => _DashboradState();
}

class _DashboradState extends State<Dashborad> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    HomeScreen.path,
    ProductionScreen.path,
    OrdersScreen.path,
    CustomerScreen.path,
    SettingsScreen.path,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        context.go(_routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'Inventory',
        ),

        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
