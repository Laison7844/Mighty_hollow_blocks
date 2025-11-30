import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/home_screen.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  static const path = '/splash';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToHome();
  }

  Future<void> _goToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go(HomeScreen.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'asset/splash_screen.png', 
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
