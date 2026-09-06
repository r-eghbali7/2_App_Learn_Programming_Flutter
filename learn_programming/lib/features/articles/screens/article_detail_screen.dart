import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/article_model.dart';

class ArticleDetailScreen extends StatefulWidget {
  final int articleId;
  const ArticleDetailScreen({super.key, required this.articleId});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool isLoading = true;
  String errorMessage = '';
  ArticleModel? article;

  final Color darkBlue = const Color(0xFF12151C);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color surfaceColor = const Color(0xFF1E222D);

  @override
  void initState() {
    super.initState();
    _fetchArticleDetails();
  }

  Future<void> _fetchArticleDetails() async {
    try {
      final dio = Dio();
      // آدرس اصلاح شده برای اجرای فلاتر روی Chrome
      final response = await dio.get(
        'http://127.0.0.1:8000/api/articles/${widget.articleId}/',
      );

      if (response.statusCode == 200) {
        setState(() {
          article = ArticleModel.fromJson(response.data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dio Error: $e');
      setState(() {
        errorMessage = 'خطا در دریافت اطلاعات. اتصال خود را بررسی کنید.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBlue,
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
            : errorMessage.isNotEmpty || article == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage.isNotEmpty ? errorMessage : 'مقاله یافت نشد',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = '';
                        });
                        _fetchArticleDetails();
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
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300.0,
          floating: false,
          pinned: true,
          backgroundColor: darkBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.white),
              onPressed: () {},
            ),
          ],
          title: Text(
            'DevFlow',
            style: TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  article!.imageUrl ??
                      'https://via.placeholder.com/600x400/12151C/FFFFFF/?text=No+Image',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/circuit_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        darkBlue.withValues(alpha: 0.3),
                        darkBlue.withValues(alpha: 0.8),
                        darkBlue,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryBadge(article!.category),
                const SizedBox(height: 12),
                Text(
                  article!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMetaData(article!.date, article!.readTime),
                const SizedBox(height: 24),
                _buildParagraph(
                  article!.content ?? 'محتوای مقاله هنوز ثبت نشده است.',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF64FFDA), fontSize: 12),
      ),
    );
  }

  Widget _buildMetaData(String date, String readTime) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today_outlined,
          color: Colors.white54,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(date, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(width: 16),
        const Icon(Icons.access_time, color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        Text(
          readTime,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.8),
    );
  }
}
