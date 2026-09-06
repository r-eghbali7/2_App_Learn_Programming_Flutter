import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'features/courses/screens/courses_list_screen.dart';
import 'features/articles/screens/articles_list_screen.dart'; // ایمپورت صفحه مقالات
import 'features/practices/screens/practice_editor_screen.dart';
import 'features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // لیست صفحاتی که با کلیک روی تب‌ها جابجا می‌شوند
  final List<Widget> _screens = [
    const HomeScreen(),
    const CoursesListScreen(),
    const ArticlesListScreen(), // اضافه شدن صفحه مقالات به تب‌ها
    const PracticeEditorScreen(),
    const ProfileScreen(),
  ];

  final Color surfaceColor = const Color(0xFF1E222D);
  final Color primaryOrange = const Color(0xFFFF8C00);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: surfaceColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryOrange,
          unselectedItemColor: Colors.white54,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'خانه',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'دوره‌ها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded), // آیکون مقالات
              label: 'مقالات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.code_rounded),
              label: 'تمرین',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'پروفایل',
            ),
          ],
        ),
      ),
    );
  }
}
