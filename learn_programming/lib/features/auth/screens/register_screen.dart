// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/home_screen.dart';
import 'login_screen.dart';
import './otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

Future<void> _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar('خطا', 'لطفاً تمام فیلدها را پر کنید.', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ۱. درخواست ارسال کد تایید (OTP)
      final response = await ApiClient().dio.post('accounts/send-otp/', data: {
        'phone_number': phone,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ۲. هدایت کاربر به صفحه OTP و ارسال نام و پسورد به آن صفحه
        if (!mounted) return;
        Get.to(() => OtpScreen(
          phoneNumber: phone,
          fullName: name,       // مهم: نام کاربر به صفحه بعد پاس داده می‌شود
          password: password,   // مهم: رمز عبور به صفحه بعد پاس داده می‌شود
        ));
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکلی در ارسال پیامک پیش آمد یا شماره نامعتبر است.', backgroundColor: AppColors.errorRed, colorText: Colors.white);
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
                const Text('ثبت‌نام در اپلیکیشن', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('برای شروع، لطفاً اطلاعات خود را وارد کنید.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 32),
                
                // فیلد نام کامل (مخصوص ثبت‌نام اولیه)
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'نام و نام خانوادگی',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),

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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // دکمه ثبت‌نام
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ثبت‌نام', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // لینک به صفحه ورود
                Center(
                  child: TextButton(
                    onPressed: () => Get.to(() => const LoginScreen()),
                    child: Text('قبلاً ثبت‌نام کرده‌اید؟ وارد شوید', style: TextStyle(color: AppColors.primaryOrange)),
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