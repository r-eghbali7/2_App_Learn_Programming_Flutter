import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart'; // ایمپورت مدل پروفایل
import '../../auth/screens/register_screen.dart'; // ایمپورت صفحه ورود برای هدایت پس از خروج
import '../../tickets/screens/ticket_screen.dart';
import '../../subscriptions/screens/subscription_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  ProfileModel? _userData; // استفاده از کلاس مدل به جای Map خام

  // رنگ‌های تم
  final Color darkBg = const Color(0xFF0F1115);
  final Color surfaceColor = const Color(0xFF161A22);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color textMuted = const Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // --- دریافت اطلاعات پروفایل از سرور ---
  Future<void> _fetchUserProfile() async {
    try {
      // کدهای واقعی برای اتصال به بک‌اند (فعلاً کامنت است تا با دیتای ماک تست کنید)
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('access_token');
      // final dio = Dio();
      // dio.options.headers['Authorization'] = 'Bearer $token';
      // final response = await dio.get('http://10.0.2.2:8000/api/core/profile/');
      // setState(() {
      //   _userData = ProfileModel.fromJson(response.data);
      //   _isLoading = false;
      // });

      // شبیه‌سازی تاخیر شبکه
      await Future.delayed(const Duration(milliseconds: 600));
      _loadMockData();
    } catch (e) {
      _loadMockData();
    }
  }

  // --- خروج از حساب کاربری ---
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // پاک کردن تمامی توکن‌ها و اطلاعات لوکال

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('با موفقیت خارج شدید.'),
        backgroundColor: Colors.green,
      ),
    );

    // هدایت به صفحه ثبت‌نام/ورود و پاک کردن تاریخچه صفحات
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
      (route) => false,
    );
  }

  void _loadMockData() {
    setState(() {
      _userData = ProfileModel(
        fullName: 'الکس جانسون',
        email: 'alex.johnson@devflow.io',
        avatarUrl: 'assets/images/avatar_large.jpg',
        streakDays: 14,
        isProUser: true,
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: _buildAppBar(),
        // BottomNavigationBar حذف شد! (در MainScreen مدیریت می‌شود)
        body: _isLoading || _userData == null
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      _buildProfileCard(),
                      const SizedBox(height: 24),
                      _buildMenu(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // --- کامپوننت‌های UI ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'DevFlow',
        style: TextStyle(
          color: primaryOrange,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
        onPressed: () {},
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              color: surfaceColor,
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

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // آواتار کاربر
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
              backgroundImage: AssetImage(_userData!.avatarUrl),
              backgroundColor: darkBg,
            ),
          ),
          const SizedBox(height: 16),

          // نام و ایمیل (داینامیک از روی مدل)
          Text(
            _userData!.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userData!.email,
            style: TextStyle(color: textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // نشان‌ها (Badges)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                icon: Icons.local_fire_department_rounded,
                iconColor: primaryOrange,
                label: 'روند ${_userData!.streakDays} روزه',
              ),
              if (_userData!.isProUser) ...[
                const SizedBox(width: 12),
                _buildBadge(
                  icon: Icons.circle,
                  iconColor: const Color(0xFF34D399), // سبز
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
        color: darkBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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

  Widget _buildMenu() {
    return Column(
      children: [
        _buildMenuItem(
          title: 'تنظیمات',
          icon: Icons.settings_outlined,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          title: 'گواهینامه‌های من',
          icon: Icons.workspace_premium_outlined,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          title: 'راهنما و پشتیبانی',
          icon: Icons.help_outline_rounded,
          onTap: () {
            // باز کردن صفحه ارسال تیکت
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TicketScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          title: 'ارتقای اشتراک و پلن‌ها',
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          title: 'خروج',
          icon: Icons.logout_rounded,
          iconColor: Colors.redAccent,
          textColor: Colors.redAccent,
          onTap: () {
            // نمایش دیالوگ خروج
            _showLogoutDialog();
          },
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
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? primaryOrange).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? primaryOrange, size: 24),
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
              color: textMuted,
              size: 16,
            ), // فلش چپ برای RTL
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'خروج از حساب',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'آیا مطمئن هستید که می‌خواهید از حساب خود خارج شوید؟',
            style: TextStyle(color: textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو', style: TextStyle(color: textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // بستن دیالوگ
                _logout(); // اجرای متد خروج و ریدایرکت
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('خروج', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
