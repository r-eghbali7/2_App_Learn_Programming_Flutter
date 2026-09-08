// lib/features/articles/controllers/article_controller.dart
import 'dart:async'; // === برای استفاده از Timer اضافه شد ===
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/article_model.dart';

class ArticleController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var articlesList = <ArticleModel>[].obs;

  // === تایمر برای جلوگیری از اسپم درخواست ===
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  // === افزودن پارامتر کوئری برای جستجو ===
  Future<void> fetchArticles({String? query}) async {
    try {
      isLoading(true);
      errorMessage('');
      
      String endpoint = 'articles/';
      if (query != null && query.isNotEmpty) {
        endpoint += '?search=$query'; // اتصال کلمه سرچ شده به آدرس
      }

      final response = await ApiClient().dio.get(endpoint);

      if (response.statusCode == 200) {
        final List data = response.data['results'] ?? response.data;
        articlesList.value = data.map((a) => ArticleModel.fromJson(a)).toList();
      }
    } catch (e) {
      if (e is DioException) {
        errorMessage('خطا در ارتباط با سرور. لطفاً اتصال خود را بررسی کنید.');
      } else {
        errorMessage('خطای ناشناخته در دریافت مقالات.');
      }
    } finally {
      isLoading(false);
    }
  }

  // === متد اجرا شدن جستجو با تایمر نیم‌ثانیه‌ای ===
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) {
        fetchArticles(query: query);
      } else if (query.isEmpty) {
        fetchArticles(); // اگر فیلد خالی شد، کل لیست دوباره لود شود
      }
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}