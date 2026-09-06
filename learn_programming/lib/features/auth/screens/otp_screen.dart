import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? fullName;
  final String? password;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.fullName,
    this.password,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  final Color darkBg = const Color(0xFF0F1115);
  final Color surfaceColor = const Color(0xFF1E222D);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color textMuted = const Color(0xFF94A3B8);

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(String code) async {
    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://127.0.0.1:8000/api/accounts/verify-otp/',
        data: {
          'phone_number': widget.phoneNumber,
          'code': code,
          if (widget.fullName != null) 'full_name': widget.fullName,
          if (widget.password != null) 'password': widget.password,
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'access_token',
          response.data['tokens']['access'],
        );
        await prefs.setString(
          'refresh_token',
          response.data['tokens']['refresh'],
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ورود با موفقیت انجام شد.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Dio OTP Error: $e');

      _otpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('کد وارد شده اشتباه است یا منقضی شده.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 52, // کمی کوچک‌تر شده تا ۵ فیلد به راحتی در صفحه جا شود
      height: 60,
      textStyle: const TextStyle(
        fontSize: 24,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        body: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryOrange.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 40.0,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phonelink_lock,
                          color: primaryOrange,
                          size: 56,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'تأیید موبایل',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'کد ۵ رقمی ارسال شده به شماره خود را وارد کنید.', // تغییر متن به ۵ رقمی
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            controller: _otpController,
                            length: 5, // تغییر تعداد رقم‌ها از ۴ به ۵
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: defaultPinTheme.copyDecorationWith(
                              border: Border.all(
                                color: primaryOrange,
                                width: 2,
                              ),
                            ),
                            submittedPinTheme: defaultPinTheme,
                            showCursor: true,
                            cursor: Container(
                              width: 2,
                              height: 24,
                              color: primaryOrange,
                            ),
                            onCompleted: (pin) {
                              _verifyOtp(pin);
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        _isLoading
                            ? CircularProgressIndicator(color: primaryOrange)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'کد دریافت نکردید؟ ',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      'ارسال مجدد',
                                      style: TextStyle(
                                        color: primaryOrange,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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