import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'article_detail_screen.dart';
import '../models/article_model.dart';

class ArticlesListScreen extends StatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  State<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends State<ArticlesListScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<ArticleModel> articles = [];

  final Color darkBg = const Color(0xFF12151C);
  final Color surfaceColor = const Color(0xFF1E222D);
  final Color primaryOrange = const Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final dio = Dio();
      // آدرس اصلاح شده برای اجرای فلاتر روی Chrome یا iOS Simulator
      final response = await dio.get('http://127.0.0.1:8000/api/articles/');

      if (response.statusCode == 200) {
        setState(() {
          articles = (response.data as List)
              .map((item) => ArticleModel.fromJson(item))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        // اگر خطایی رخ داد، لاگ آن را در کنسول چاپ می‌کنیم تا ببینید مشکل چیست
        debugPrint('Dio Error: $e');
        errorMessage = 'خطا در ارتباط با سرور. لطفا اتصال خود را بررسی کنید.';
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
        body: SafeArea(
          child: isLoading
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = '';
                          });
                          _fetchArticles();
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
              : Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 24),
                          ...List.generate(articles.length, (index) {
                            return _buildArticleCard(articles[index]);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
          const Text(
            'DevFlow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/avatar.jpg'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'آخرین مقالات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'بینش‌ها و بروزرسانی‌ها از دنیای توسعه.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildArticleCard(ArticleModel article) {
    Color badgeColor = Colors.blue.withValues(alpha: 0.2);
    Color badgeTextColor = Colors.blueAccent;

    if (article.category == 'هوش مصنوعی') {
      badgeColor = const Color(0xFF0F3460);
      badgeTextColor = const Color(0xFF8AB4F8);
    } else if (article.category == 'معماری') {
      badgeColor = const Color(0xFF004D40).withValues(alpha: 0.5);
      badgeTextColor = const Color(0xFF64FFDA);
    } else {
      badgeColor = const Color(0xFF1A1A3A);
      badgeTextColor = const Color(0xFFB39DDB);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(articleId: article.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                article.imageUrl ??
                    'https://via.placeholder.com/600x400/1E222D/FFFFFF/?text=No+Image',
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 160,
                  color: Colors.grey.shade900,
                  child: const Icon(
                    Icons.image,
                    color: Colors.white24,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                article.category,
                style: TextStyle(
                  color: badgeTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              article.summary,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
                height: 1.6,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.arrow_back, color: Color(0xFFFF8C00), size: 16),
                SizedBox(width: 6),
                Text(
                  'ادامه مطلب',
                  style: TextStyle(
                    color: Color(0xFFFF8C00),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
