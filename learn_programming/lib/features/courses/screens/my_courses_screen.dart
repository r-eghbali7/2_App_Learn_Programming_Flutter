// lib/features/courses/screens/my_courses_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import 'course_detail_screen.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تزریق کنترلر
    final MyCoursesController controller = Get.put(MyCoursesController());

    final Color darkBg = const Color(0xFF0F1115);
    final Color surfaceColor = const Color(0xFF161A22);
    final Color primaryOrange = const Color(0xFFFF8C00);
    final Color successGreen = const Color(0xFF34D399);
    final Color textMuted = const Color(0xFF94A3B8);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        body: SafeArea(
          // استفاده از Obx
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: primaryOrange),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: textMuted),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchMyCourses(),
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
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'دوره‌های من',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'به مسیر یادگیری خود ادامه دهید.',
                    style: TextStyle(color: textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // بررسی خالی بودن لیست
                  if (controller.myCoursesList.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Text(
                          'شما هنوز در هیچ دوره‌ای ثبت‌نام نکرده‌اید.',
                          style: TextStyle(color: textMuted),
                        ),
                      ),
                    )
                  else
                    // نمایش لیست دوره‌ها
                    ...controller.myCoursesList.map(
                      (course) => _buildCourseCard(
                        course,
                        surfaceColor,
                        primaryOrange,
                        successGreen,
                        textMuted,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // === متدهای UI ===

  Widget _buildCourseCard(
    MyCourseModel course,
    Color surfaceColor,
    Color primaryOrange,
    Color successGreen,
    Color textMuted,
  ) {
    Color themeColor = course.isCompleted ? successGreen : primaryOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: themeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              course.status,
              style: TextStyle(
                color: themeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            course.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.description,
            style: TextStyle(color: textMuted, fontSize: 13, height: 1.6),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('پیشرفت', style: TextStyle(color: textMuted, fontSize: 12)),
              Text(
                '${(course.progress * 100).toInt()}%',
                style: TextStyle(
                  color: themeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: course.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF0F1115),
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                course.modulesText,
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
              Row(
                children: [
                  // === دکمه دریافت گواهینامه (فقط اگر ۱۰۰٪ شده باشد) ===
                  if (course.isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // باز کردن لینک دانلود گواهینامه
                          // می‌توانید با استفاده از url_launcher مرورگر را باز کنید
                          // یا عکسی که از مسیر api/courses/{course.id}/certificate می‌آید را دانلود کنید
                          Get.snackbar(
                            'تبریک!',
                            'در حال آماده‌سازی گواهینامه شما...',
                            backgroundColor: Colors.amber,
                            colorText: Colors.black,
                          );
                        },
                        icon: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 16,
                          color: Colors.black87,
                        ),
                        label: const Text(
                          'گواهینامه',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.amber, // رنگ طلایی ویژه گواهینامه
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  // === دکمه ادامه دوره ===
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => CourseDetailScreen(courseId: course.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          course.isCompleted ? 'مرور دوره' : 'ادامه',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_back_rounded, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
