import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/dashborad.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  static String path = "/customer-screen";
  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Customers List"),
      bottomNavigationBar: Dashborad(),
    );
  }
}
