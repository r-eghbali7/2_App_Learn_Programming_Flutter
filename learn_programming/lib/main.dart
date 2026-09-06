import 'package:flutter/material.dart';
import 'package:learn_programming/features/home/screens/landing_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart'; // صفحه اصلی شامل نوار پایین و خانه

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // بررسی وجود توکن در حافظه محلی
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  runApp(DevFlowApp(isLoggedIn: token != null && token.isNotEmpty));
}

class DevFlowApp extends StatelessWidget {
  final bool isLoggedIn;
  const DevFlowApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevFlow',
      // اگر کاربر لاگین کرده بود MainScreen (خانه) را نشان بده، در غیر این صورت LandingScreen (ثبت‌نام/ورود)
      home: isLoggedIn ? const MainScreen() : const LandingScreen(),
    );
  }
}