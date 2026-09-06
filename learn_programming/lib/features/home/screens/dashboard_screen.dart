import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/dashboard_model.dart'; // ایمپورت مدل داشبورد

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  DashboardModel? _dashboardData;

  final Color darkBg = const Color(0xFF0F1522);
  final Color surfaceColor = const Color(0xFF161C2D);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color textMuted = const Color(0xFF94A3B8);

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final dio = Dio();
      // تنظیم آدرس روی 127.0.0.1 برای کروم
      final response = await dio.get('http://127.0.0.1:8000/api/dashboard/');

      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = DashboardModel.fromJson(response.data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard API Error: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    setState(() {
      _dashboardData = DashboardModel(
        activeProjects: 12,
        openReviews: 5,
        latestChanges: [
          ChangeModel(
            title: 'به‌روزرسانی ماژول احراز هویت',
            subtitle: '۲ ساعت پیش توسط امیر',
            status: 'تایید شده',
            statusColor: 0xFF059669,
            iconCodePoint: 0,
            iconBg: 0xFF4B1916,
            iconColor: 0xFFF97316,
          ),
          ChangeModel(
            title: 'مستندات API جدید',
            subtitle: 'دیروز توسط سارا',
            status: 'در انتظار',
            statusColor: 0xFFD97706,
            iconCodePoint: 0,
            iconBg: 0xFF1E3A8A,
            iconColor: 0xFF60A5FA,
          ),
          ChangeModel(
            title: 'رفع خطای حافظه در سرور',
            subtitle: '۳ روز پیش توسط رضا',
            status: 'بسته شده',
            statusColor: 0xFF475569,
            iconCodePoint: 0,
            iconBg: 0xFF2E1065,
            iconColor: 0xFFA78BFA,
          ),
        ],
      );
      _isLoading = false;
    });
  }

  IconData _getIconForChange(String title) {
    if (title.contains('ماژول')) return Icons.code_rounded;
    if (title.contains('مستندات')) return Icons.description_outlined;
    if (title.contains('خطا')) return Icons.bug_report_outlined;
    return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: _buildAppBar(),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: primaryOrange,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomAppBar(),
        body: _isLoading || _dashboardData == null
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 32),
                      _buildChangesHeader(),
                      const SizedBox(height: 16),
                      _buildChangesList(),
                      const SizedBox(height: 24),
                      _buildPromoBanner(),
                      const SizedBox(height: 40),
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
      centerTitle: true,
      title: const Text(
        'CodeGlass',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {},
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo_icon.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    Container(width: 32, height: 32, color: Colors.white24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'جستجو در کدها...',
          hintStyle: TextStyle(color: textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: textMuted),
          suffixIcon: Icon(Icons.tune_rounded, color: textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'پروژه‌های فعال',
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dashboardData!.activeProjects}',
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'بازبینی‌های باز',
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_dashboardData!.openReviews}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'آخرین تغییرات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Text(
            'مشاهده همه',
            style: TextStyle(
              color: primaryOrange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangesList() {
    return Column(
      children: _dashboardData!.latestChanges.map((change) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(change.iconBg),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForChange(change.title),
                    color: Color(change.iconColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        change.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        change.subtitle,
                        style: TextStyle(color: textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(change.statusColor).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    change.status,
                    style: TextStyle(
                      color: Color(change.statusColor),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C00), Color(0xFFE85D04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نسخه پیشرفته CodeGlass',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'با استفاده از هوش مصنوعی، خطاهای کد خود را قبل از اجرا شناسایی کنید.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ارتقا دهید',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: surfaceColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.dashboard_rounded, 'پیشخوان', 0),
            _buildNavItem(Icons.folder_outlined, 'پروژه‌ها', 1),
            const SizedBox(width: 48),
            _buildNavItem(Icons.history_rounded, 'تاریخچه', 2),
            _buildNavItem(Icons.person_outline_rounded, 'پروفایل', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? primaryOrange : textMuted, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryOrange : textMuted,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
