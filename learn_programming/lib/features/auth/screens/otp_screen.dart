// lib/features/auth/screens/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class OtpScreen extends StatelessWidget {
  final String phoneNumber;
  final String? fullName;
  final String? password;

  const OtpScreen({super.key, required this.phoneNumber, this.fullName, this.password});

  @override
  Widget build(BuildContext context) {
    // پیدا کردن کنترلری که در صفحه قبل ساخته بودیم
    final AuthController controller = Get.find<AuthController>();

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.primaryOrange.withValues(alpha: 0.15), Colors.transparent],
                    radius: 0.6,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWithOpacity,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phonelink_lock, color: AppColors.primaryOrange, size: 56),
                        const SizedBox(height: 24),
                        const Text('تأیید موبایل', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('کد ۵ رقمی ارسال شده به شماره خود را وارد کنید.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5)),
                        const SizedBox(height: 32),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            controller: controller.otpController,
                            length: 5,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: defaultPinTheme.copyDecorationWith(border: Border.all(color: AppColors.primaryOrange, width: 2)),
                            submittedPinTheme: defaultPinTheme,
                            showCursor: true,
                            cursor: Container(width: 2, height: 24, color: AppColors.primaryOrange),
                            onCompleted: (pin) {
                              // فراخوانی متد کنترلر با اطلاعات کاربر
                              controller.verifyOtp(phoneNumber, pin, fullName: fullName, password: password);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        Obx(() => controller.isLoading.value
                            ? const CircularProgressIndicator(color: AppColors.primaryOrange)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('کد دریافت نکردید؟ ', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                  GestureDetector(
                                    onTap: () => controller.sendOtp(), // استفاده از کنترلر برای ارسال مجدد
                                    child: const Text('ارسال مجدد', style: TextStyle(color: AppColors.primaryOrange, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}