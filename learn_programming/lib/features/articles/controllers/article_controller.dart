// lib/features/articles/controllers/article_controller.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/article_model.dart';

class ArticleController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var articlesList = <ArticleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    try {
      isLoading(true);
      errorMessage('');
      
      // استفاده از سرویس متمرکز شبکه
      final response = await ApiClient().dio.get('articles/');

      if (response.statusCode == 200) {
        // چون Pagination فعال شده، دیتا داخل 'results' قرار دارد
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
}