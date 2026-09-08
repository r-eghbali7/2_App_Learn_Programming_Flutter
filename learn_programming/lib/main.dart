import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/home/screens/landing_screen.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');

  runApp(DevFlowApp(isLoggedIn: token != null && token.isNotEmpty));
}

class DevFlowApp extends StatelessWidget {
  final bool isLoggedIn;
  const DevFlowApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeGlass',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Vazirmatn', 
      ),
      // === تنظیم انیمیشن پیش‌فرض برای کل صفحات ===
      defaultTransition: Transition.fadeIn, 
      transitionDuration: const Duration(milliseconds: 400),
      
      home: isLoggedIn ? const MainScreen() : const LandingScreen(),
    );
  }
}