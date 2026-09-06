import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/course_model.dart';
import 'course_detail_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  bool _isLoading = true;
  List<MyCourseModel> _myCourses = [];

  final Color darkBg = const Color(0xFF0F1115);
  final Color surfaceColor = const Color(0xFF161A22);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color successGreen = const Color(0xFF34D399);
  final Color textMuted = const Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _fetchMyCourses();
  }

  Future<void> _fetchMyCourses() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://127.0.0.1:8000/api/courses/my-courses/',
      );
      if (response.statusCode == 200) {
        setState(() {
          _myCourses = (response.data as List)
              .map((c) => MyCourseModel.fromJson(c))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('My Courses Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : SafeArea(
                child: SingleChildScrollView(
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
                      if (_myCourses.isEmpty)
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
                        ..._myCourses.map((course) => _buildCourseCard(course)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCourseCard(MyCourseModel course) {
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
              backgroundColor: darkBg,
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
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseDetailScreen(courseId: course.id),
                    ),
                  );
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
                child: const Row(
                  children: [
                    Text(
                      'ادامه',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_back_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
