import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home_model.dart';
import '../../courses/models/course_model.dart';
import '../../articles/models/article_model.dart';
import '../../courses/screens/course_detail_screen.dart';
import '../../articles/screens/article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String errorMessage = '';

  List<BannerModel> banners = [];
  UserProfileModel? userProfile;
  List<CourseModel> latestCourses = [];
  List<ArticleModel> latestArticles = [];

  final Color darkBg = const Color(0xFF12151C);
  final Color surfaceColor = const Color(0xFF1E222D);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color tealAccent = const Color(0xFF64FFDA);

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final dio = Dio();
      // ارسال توکن احراز هویت در هدر برای جلوگیری از خطاهای دسترسی (401/404)
      final response = await dio.get(
        'http://127.0.0.1:8000/api/core/home/',
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          if (data['banners'] != null) {
            banners = (data['banners'] as List)
                .map((b) => BannerModel.fromJson(b))
                .toList();
          }
          if (data['user'] != null) {
            userProfile = UserProfileModel.fromJson(data['user']);
          }
          if (data['latest_courses'] != null) {
            latestCourses = (data['latest_courses'] as List)
                .map((c) => CourseModel.fromJson(c))
                .toList();
          }
          if (data['latest_articles'] != null) {
            latestArticles = (data['latest_articles'] as List)
                .map((a) => ArticleModel.fromJson(a))
                .toList();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Home API Error: $e');
      setState(() {
        errorMessage = 'خطا در ارتباط با سرور. لطفاً اتصال خود را بررسی کنید.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        body: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = '';
                        });
                        _fetchHomeData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                      ),
                      child: const Text(
                        'تلاش مجدد',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildBanner(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('همه دوره‌ها', hasViewAll: true),
                      const SizedBox(height: 16),
                      _buildCoursesList(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('جدیدترین مقالات', hasViewAll: false),
                      const SizedBox(height: 16),
                      _buildArticlesList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final String displayName = userProfile?.fullName.isNotEmpty == true
        ? userProfile!.fullName
        : 'کاربر گرامی';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سلام، $displayName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'آماده نوشتن کد هستی؟',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    final banner = banners.isNotEmpty ? banners[0] : null;
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: banner?.imageUrl != null
              ? NetworkImage(banner!.imageUrl!) as ImageProvider
              : const AssetImage('assets/images/banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ویژه',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              banner?.title ?? 'بدون بنر',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool hasViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (hasViewAll)
          Text(
            'مشاهده همه',
            style: TextStyle(
              color: primaryOrange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildCoursesList() {
    if (latestCourses.isEmpty) {
      return const Text(
        'دوره‌ای یافت نشد.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: latestCourses.length,
        itemBuilder: (context, index) {
          final course = latestCourses[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(courseId: course.id),
                ),
              );
            },
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      course.thumbnail ??
                          'https://via.placeholder.com/600x400/1E222D/FFFFFF/?text=Course',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(height: 120, color: Colors.grey.shade900),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                course.instructor,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticlesList() {
    if (latestArticles.isEmpty) {
      return const Text(
        'مقاله‌ای یافت نشد.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: latestArticles.length,
      itemBuilder: (context, index) {
        final article = latestArticles[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ArticleDetailScreen(articleId: article.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    article.imageUrl ??
                        'https://via.placeholder.com/600x400/1E222D/FFFFFF/?text=Article',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.summary,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.readTime,
                        style: TextStyle(
                          color: tealAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
