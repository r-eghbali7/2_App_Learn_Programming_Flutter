class ArticleModel {
  final int id;
  final String title;
  final String summary;
  final String? imageUrl;
  final String? content;
  final String category;
  final String date;
  final String readTime;

  ArticleModel({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
    this.content,
    this.category = 'برنامه‌نویسی',
    this.date = 'تازه‌ها',
    this.readTime = '۵ دقیقه مطالعه',
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    // تبدیل تاریخ فرمت ISO از جنگو به تاریخ خوانا
    String formattedDate = 'تازه‌ها';
    if (json['created_at'] != null) {
      formattedDate = json['created_at'].toString().split('T')[0];
    }

    return ArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      summary: json['summary'] ?? '',
      // دقت کنید: در API جنگوی شما نام این فیلد image است
      imageUrl: json['image'],
      content: json['content'],
      category: json['category'] ?? 'برنامه‌نویسی',
      date: formattedDate,
      readTime: json['read_time'] ?? '۵ دقیقه مطالعه',
    );
  }
}
