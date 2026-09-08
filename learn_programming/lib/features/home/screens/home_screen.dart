// lib/features/home/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../HomeController/home_controller.dart';
import '../../courses/screens/course_detail_screen.dart';
import '../../courses/screens/courses_list_screen.dart';
import '../../articles/screens/article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final HomeController controller = Get.find<HomeController>();
      if (controller.banners.isNotEmpty) {
        if (_currentPage < controller.banners.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: SpinKitThreeBounce(
                color: AppColors.primaryOrange,
                size: 30,
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white54,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchHomeData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                    ),
                    child: const Text(
                      'تلاش مجدد',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(controller),
                  const SizedBox(height: 24),
                  _buildBannerSlider(controller),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    'همه دوره‌ها',
                    hasViewAll: true,
                    onViewAllTap: () => Get.to(() => const CoursesListScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildCoursesList(controller),
                  const SizedBox(height: 32),
                  _buildSectionTitle('جدیدترین مقالات', hasViewAll: false),
                  const SizedBox(height: 16),
                  _buildArticlesList(controller),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // === این متد مطابق با درخواست شما تغییر کرد ===
  Widget _buildHeader(HomeController controller) {
    final userProfile = controller.userProfile.value;
    final String displayName = userProfile?.fullName.isNotEmpty == true
        ? userProfile!.fullName
        : 'کاربر گرامی';

    // خواندن روزهای باقیمانده و تعیین وضعیت رنگی
    final int remainingDays = userProfile?.subscriptionRemainingDays ?? 0;
    final bool isExpiringSoon = remainingDays < 10;
    final bool hasSubscription = remainingDays > 0;

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
                const SizedBox(height: 4), // یک فاصله کوچک
                // === نمایش وضعیت حساب کاربری ===
                if (hasSubscription)
                  Text(
                    'اعتبار اشتراک: $remainingDays روز',
                    style: TextStyle(
                      color: isExpiringSoon
                          ? AppColors.errorRed
                          : const Color(
                              0xFF34D399,
                            ), // زیر 10 روز قرمز، در غیر اینصورت سبز
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
                    'شما اشتراک فعالی ندارید',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
        // === بخش مربوط به Container زنگوله کلا حذف شد ===
      ],
    );
  }

  Widget _buildBannerSlider(HomeController controller) {
    if (controller.banners.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'بنری موجود نیست',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: controller.banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = controller.banners[index];
              return GestureDetector(
                onTap: () {
                  if (banner.courseId != null) {
                    Get.to(
                      () => CourseDetailScreen(courseId: banner.courseId!),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: banner.imageUrl != null
                          ? NetworkImage(banner.imageUrl!) as ImageProvider
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
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
                          banner.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            controller.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage == index ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentPage == index
                    ? AppColors.primaryOrange
                    : Colors.white24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title, {
    required bool hasViewAll,
    VoidCallback? onViewAllTap,
  }) {
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
          InkWell(
            onTap: onViewAllTap,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'مشاهده همه',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCoursesList(HomeController controller) {
    if (controller.latestCourses.isEmpty) {
      return const Text(
        'دوره‌ای یافت نشد.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return SizedBox(
      height: 350,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.latestCourses.length,
        itemBuilder: (context, index) {
          final course = controller.latestCourses[index];
          return GestureDetector(
                onTap: () =>
                    Get.to(() => CourseDetailScreen(courseId: course.id)),
                child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
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
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: 240,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
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
                            const SizedBox(height: 6),
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
              )
              .animate()
              .fade(duration: 400.ms, delay: (index * 100).ms)
              .slideX(begin: 0.1, end: 0, duration: 400.ms);
        },
      ),
    );
  }

  Widget _buildArticlesList(HomeController controller) {
    if (controller.latestArticles.isEmpty) {
      return const Text(
        'مقاله‌ای یافت نشد.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.latestArticles.length,
      itemBuilder: (context, index) {
        final article = controller.latestArticles[index];
        return GestureDetector(
              onTap: () =>
                  Get.to(() => ArticleDetailScreen(articleId: article.id)),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
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
                            style: const TextStyle(
                              color: const Color(0xFF64FFDA),
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
            )
            .animate()
            .fade(duration: 400.ms, delay: (index * 100).ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms);
      },
    );
  }
}
