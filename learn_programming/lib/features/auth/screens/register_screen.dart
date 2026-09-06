// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'otp_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // کنترلرهای فیلدهای ثبت‌نام
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // پیدا کردن کنترلر مرکزی احراز هویت
    final AuthController authController = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Stack(
          children: [
            _buildBackgroundGlow(),
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
                      color: AppColors.surfaceWithOpacity,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'CodeGlass',
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ایجاد حساب کاربری',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'سفر توسعه‌دهنده خود را آغاز کنید.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 40),
                        
                        // فیلد نام کامل
                        _buildInputField(
                          label: 'نام کامل',
                          hint: 'علی احمدی',
                          controller: _nameController,
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 20),

                        // فیلد شماره موبایل (متصل به AuthController)
                        _buildInputField(
                          label: 'شماره موبایل',
                          hint: '09123456789',
                          controller: authController.phoneController,
                          icon: Icons.phone_android_rounded,
                          isNumber: true,
                        ),
                        const SizedBox(height: 20),

                        // فیلد رمز عبور
                        _buildPasswordInputField(
                          label: 'رمز عبور',
                          hint: '••••••',
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 40),

                        // دکمه ثبت‌نام
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Obx(() => ElevatedButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : () => _submitRegister(authController),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  elevation: 0,
                                ),
                                child: authController.isLoading.value
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
                                            'ثبت‌نام و دریافت کد',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_back_rounded, size: 20),
                                        ],
                                      ),
                              )),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'حساب کاربری دارید؟ ',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () => Get.off(() => const LoginScreen()),
                              child: const Text(
                                'وارد شوید',
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
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

  // اعتبارسنجی فرم ثبت‌نام و هدایت به صفحه OTP با پاس دادن نام و پسورد
  void _submitRegister(AuthController authController) {
    final name = _nameController.text.trim();
    final phone = authController.phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar('خطا', 'لطفاً تمامی فیلدها را پر کنید.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (!RegExp(r'^09\d{9}$').hasMatch(phone)) {
      Get.snackbar('خطا', 'شماره موبایل معتبر نیست.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (password.length < 6) {
      Get.snackbar('خطا', 'رمز عبور باید حداقل ۶ کاراکتر باشد.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // ارسال درخواست OTP از طریق کنترلر و سپس هدایت به صفحه تایید کد
    authController.sendOtp().then((_) {
      // اگر خطا رخ نداده باشد و کاربر به صفحه بعد رفت، نام و پسورد را همراه شماره به OtpScreen می‌فرستیم
      if (!authController.isLoading.value) {
        Get.to(() => OtpScreen(
              phoneNumber: phone,
              fullName: name,
              password: password,
            ));
      }
    });
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      left: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primaryOrange.withValues(alpha: 0.15),
              Colors.transparent,
            ],
            radius: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isNumber = false,
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
            keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
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

  Widget _buildPasswordInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
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
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade500, size: 22),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
        ),
      ],
    );
  }
}