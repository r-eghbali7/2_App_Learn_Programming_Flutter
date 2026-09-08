// lib/features/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../screens/otp_screen.dart';
import '../../../main_screen.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  
  // کنترلرهای تکست‌فیلد را اینجا نگه می‌داریم تا وقتی کاربر از برنامه خارج شد، از حافظه رم پاک شوند
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  // --- ارسال پیامک ---
  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty || !RegExp(r'^09\d{9}$').hasMatch(phone)) {
      Get.snackbar('خطا', 'شماره موبایل وارد شده معتبر نیست.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading(true);
    try {
      final response = await ApiClient().dio.post(
        'accounts/send-otp/',
        data: {'phone_number': phone},
      );

      if (response.statusCode == 200) {
        Get.snackbar('موفق', 'کد تایید برای شما ارسال شد.', backgroundColor: Colors.green, colorText: Colors.white);
        // هدایت به صفحه OTP و پاس دادن شماره موبایل
        Get.to(() => OtpScreen(phoneNumber: phone));
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکل در ارتباط با سرور یا شماره مسدود است.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // --- تایید کد و ورود ---
  Future<void> verifyOtp(String phone, String code, {String? fullName, String? password}) async {
    isLoading(true);
    try {
      final data = {
        'phone_number': phone,
        'code': code,
      };
      if (fullName != null) data['full_name'] = fullName;
      if (password != null) data['password'] = password;

      final response = await ApiClient().dio.post('accounts/verify-otp/', data: data);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', response.data['tokens']['access']);
        await prefs.setString('refresh_token', response.data['tokens']['refresh']);

        Get.snackbar('خوش آمدید', 'ورود با موفقیت انجام شد.', backgroundColor: Colors.green, colorText: Colors.white);
        
        // پاک کردن کامل تاریخچه صفحات و ورود به صفحه اصلی
        Get.offAll(() => const MainScreen());
      }
    } catch (e) {
      otpController.clear();
      Get.snackbar('خطا', 'کد وارد شده اشتباه است یا منقضی شده.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}