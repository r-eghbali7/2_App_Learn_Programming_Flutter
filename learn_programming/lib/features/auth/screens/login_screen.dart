// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';
import 'register_screen.dart'; // برای رفتن به صفحه ثبت‌نام اگر حساب ندارد

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      Get.snackbar(
        'خطا',
        'لطفاً شماره موبایل و رمز عبور را وارد کنید.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // تغییر ۱: اصلاح مسیر از auth/login به accounts/login
      final response = await ApiClient().dio.post(
        'accounts/login/',
        data: {'phone_number': phone, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // گرفتن کلید access که در ویوی جنگو تعریف کرده‌اید
        final accessToken = response.data['access'];
        final refreshToken = response.data['refresh'];

        final prefs = await SharedPreferences.getInstance();

        // تغییر ۲: ذخیره با نام صحیح access_token تا main.dart آن را بشناسد
        await prefs.setString('access_token', accessToken);

        // ذخیره رفرش توکن برای استفاده در ApiClient
        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
        }

        if (!mounted) return;
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'شماره موبایل یا رمز عبور اشتباه است.',
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ورود به حساب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'خوش آمدید! لطفاً اطلاعات ورود خود را وارد کنید.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 32),

                // فیلد شماره موبایل
                TextField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'شماره موبایل',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // فیلد پسورد
                TextField(
                  controller: _passwordController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'رمز عبور',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // دکمه ورود
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'ورود',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // لینک به صفحه ثبت‌نام
                Center(
                  child: TextButton(
                    onPressed: () => Get.to(() => const RegisterScreen()),
                    child: Text(
                      'حساب ندارید؟ ثبت‌نام کنید',
                      style: TextStyle(color: AppColors.primaryOrange),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
