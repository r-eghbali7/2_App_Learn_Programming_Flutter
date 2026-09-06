import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../auth/screens/otp_screen.dart'; // هدایت به صفحه تایید کد
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  final Color darkBg = const Color(0xFF0F1115);
  final Color surfaceColor = const Color(0xFF1E222D);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color textMuted = const Color(0xFF94A3B8);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showSnackBar('لطفاً شماره موبایل خود را وارد کنید.', Colors.red);
      return;
    }

    if (!RegExp(r'^09\d{9}$').hasMatch(phone)) {
      _showSnackBar('شماره موبایل معتبر نیست.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio();
      // استفاده از همان اندپوینتی که در جنگو دارید: send-otp
      final response = await dio.post(
        'http://127.0.0.1:8000/api/accounts/send-otp/',
        data: {'phone_number': phone},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        _showSnackBar('کد تایید برای شما ارسال شد.', Colors.green);

        // هدایت به صفحه وارد کردن کد تایید (OTP)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              phoneNumber: phone,
              // چون کاربر از قبل ثبت‌نام کرده، نیازی به ارسال نام و پسورد جدید نیست
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Login Send-OTP Error: $e');
      _showSnackBar('خطا در ارتباط با سرور یا شماره ثبت نشده است.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
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
                        Text(
                          'DevFlow',
                          style: TextStyle(
                            color: primaryOrange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ورود به حساب کاربری',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'شماره موبایل خود را وارد کنید تا کد تایید ارسال شود.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 40),
                        _buildInputField(
                          label: 'شماره موبایل',
                          hint: '09123456789',
                          controller: _phoneController,
                          icon: Icons.phone_android_rounded,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ارسال کد تایید',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_back_rounded, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حساب کاربری ندارید؟ ',
                              style: TextStyle(color: textMuted, fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'ثبت‌نام کنید',
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}
