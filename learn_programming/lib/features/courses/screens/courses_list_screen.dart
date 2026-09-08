// lib/features/courses/screens/courses_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // اضافه شده
import 'package:flutter_animate/flutter_animate.dart'; // اضافه شده
import '../controllers/course_controller.dart';
import '../models/course_model.dart';
import 'course_detail_screen.dart';

class CoursesListScreen extends StatelessWidget {
  const CoursesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseController controller = Get.put(CourseController());

    final Color darkBg = const Color(0xFF12151C);
    final Color surfaceColor = const Color(0xFF1E222D);
    final Color primaryOrange = const Color(0xFFFF8C00);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              // === لودینگ زیبای جدید ===
              return Center(child: SpinKitThreeBounce(color: primaryOrange, size: 30));
            }
            
            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 48),
                    const SizedBox(height: 16),
                    Text(controller.errorMessage.value, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.fetchCourses(),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
                      child: const Text('تلاش مجدد', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildTopBar(surfaceColor),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSearchBar(surfaceColor, controller),
                        const SizedBox(height: 24),
                        
                        // === رندر کردن لیست دوره‌ها با انیمیشن تاخیری ===
                        ...controller.coursesList.asMap().entries.map(
                          (entry) => _buildCourseCard(entry.value, surfaceColor)
                              .animate()
                              .fade(duration: 400.ms, delay: (entry.key * 75).ms) // هر کارت کمی دیرتر ظاهر می‌شود
                              .slideY(begin: 0.1, end: 0, duration: 400.ms),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopBar(Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
          const Text('CodeGlass', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('دوره‌های موجود', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('تخصص فنی خود را گسترش دهید و مفاهیم اصلی را عمیقاً درک کنید.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.6)),
      ],
    );
  }

// === کنترلر به عنوان پارامتر ورودی اضافه شد ===
  Widget _buildSearchBar(Color surfaceColor, CourseController controller) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        // === اتصال فیلد متنی به کنترلر برای لایو سرچ ===
        onChanged: controller.onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'جستجوی دوره‌ها...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course, Color surfaceColor) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CourseDetailScreen(courseId: course.id));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                course.thumbnail ?? 'https://via.placeholder.com/600x400/1E293B/FFFFFF/?text=Course',
                width: double.infinity, height: 160, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 160, color: Colors.grey.shade900, child: const Icon(Icons.image, color: Colors.white24, size: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 14, color: Colors.white)),
                      const SizedBox(width: 8),
                      Text(course.instructor, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}