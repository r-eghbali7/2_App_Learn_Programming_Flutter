// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/profile_controller.dart';
import '../../auth/screens/register_screen.dart';
import '../../tickets/screens/ticket_screen.dart';
import '../../subscriptions/screens/subscription_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../subscriptions/screens/purchases_screen.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تزریق کنترلر پروفایل
    final ProfileController controller = Get.put(ProfileController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: _buildAppBar(context),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.errorMessage.value, style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchUserProfile(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                    child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final userData = controller.userData.value;
          if (userData == null) {
            return const Center(child: Text('کاربری یافت نشد.', style: TextStyle(color: Colors.white54)));
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                children: [
                  _buildProfileCard(userData),
                  const SizedBox(height: 24),
                  _buildMenu(context),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBg,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'DevFlow',
        style: TextStyle(
          color: AppColors.primaryOrange,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      // جایگزینی زنگوله با دکمه بازگشت به عقب
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              color: AppColors.surfaceColor,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildProfileCard(userData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(userData.avatarUrl),
              backgroundColor: AppColors.darkBg,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userData.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userData.email,
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.primaryOrange,
                label: 'روند ${userData.streakDays} روزه',
              ),
              if (userData.isProUser) ...[
                const SizedBox(width: 12),
                _buildBadge(
                  icon: Icons.circle,
                  iconColor: AppColors.successGreen,
                  label: 'کاربر حرفه‌ای',
                  iconSize: 10,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color iconColor,
    required String label,
    double iconSize = 16,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          title: 'مدیریت اشتراک‌ها',
          icon: Icons.subscriptions_rounded,
          onTap: () {
            Get.to(() => const SubscriptionScreen());
          },
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          title: 'خریدهای من',
          icon: Icons.shopping_bag_rounded,
          onTap: () {
            Get.to(() => const PurchasesScreen());
          },
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          title: 'تیکت‌های من',
          icon: Icons.support_agent_rounded,
          onTap: () {
            Get.to(() => const TicketScreen());
          },
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          title: 'خروج از حساب',
          icon: Icons.logout_rounded,
          iconColor: AppColors.errorRed,
          textColor: AppColors.errorRed,
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }


  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryOrange).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primaryOrange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'خروج از حساب',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
            style: TextStyle(color: AppColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!context.mounted) return;
                Navigator.pop(context);
                Get.offAll(() => const RegisterScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
              child: const Text('خروج', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}