import 'package:flutter/material.dart';
import 'package:learn_programming/features/auth/screens/login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final Color darkBg = const Color(0xFF0B1120);
  final Color surfaceColor = const Color(0xFF131A2A);
  final Color primaryOrange = const Color(0xFFFF7A00);
  final Color textMuted = const Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeroSection(),
                const SizedBox(height: 48),
                _buildFeaturesList(),
                const SizedBox(height: 48),
                _buildRepoSearchSection(),
                const SizedBox(height: 48),
                _buildStatsSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkBg,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'CodeGlass',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.code_rounded,
              color: Colors.black,
              size: 16,
            ),
          ),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.search, color: Colors.white),
        onPressed: () {},
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'ورود',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: primaryOrange, size: 14),
              const SizedBox(width: 8),
              Text(
                'نسخه جدید ۲.۰ منتشر شد',
                style: TextStyle(
                  color: primaryOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'کدهای خود را با '),
              TextSpan(
                text: 'دقت بالا\n',
                style: TextStyle(color: primaryOrange),
              ),
              const TextSpan(text: 'تحلیل کنید'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ابزاری قدرتمند برای بازبینی کدها، شناسایی خطاها\nو بهبود کارایی پروژه‌های برنامه‌نویسی شما.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textMuted, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'شروع رایگان',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.rocket_launch_rounded, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'مشاهده دمو',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureCard(
          title: 'تحلیل هوشمند کد',
          description:
              'با استفاده از هوش مصنوعی، کدهای شما را در لحظه بررسی کرده و پیشنهادات بهینه‌سازی ارائه می‌دهیم.',
          icon: Icons.code_rounded,
          color: const Color(0xFFD97706),
        ),
        _buildFeatureCard(
          title: 'رابط کاربری شیشه‌ای',
          description:
              'طراحی مدرن و مینیمال که تمرکز شما را بر روی مهم‌ترین بخش یعنی کدها حفظ می‌کند.',
          icon: Icons.remove_red_eye_outlined,
          color: const Color(0xFF3B82F6),
        ),
        _buildFeatureCard(
          title: 'سرعت فوق‌العاده',
          description:
              'بدون هیچ تاخیری پروژه‌های بزرگ خود را بارگذاری و از ابزارهای آنالیز استفاده کنید.',
          icon: Icons.speed_rounded,
          color: const Color(0xFF10B981),
        ),
        _buildFeatureCard(
          title: 'امنیت تضمین شده',
          description:
              'اطلاعات و کدهای شما با بالاترین استانداردهای رمزنگاری محافظت می‌شوند.',
          icon: Icons.shield_outlined,
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: textMuted, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoSearchSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Text(
            'جستجوی هوشمند در کدها',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'آدرس مخزن (Repository) خود را وارد کنید',
            style: TextStyle(color: textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: darkBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'github.com/username/repo',
                        hintStyle: TextStyle(
                          color: textMuted.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: textMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'تحلیل',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('+50K', 'برنامه‌نویس'),
        _buildStatItem('+1M', 'خط کد تحلیل شده'),
        _buildStatItem('100%', 'امنیت داده‌ها'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: primaryOrange,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: textMuted, fontSize: 11)),
      ],
    );
  }
}
