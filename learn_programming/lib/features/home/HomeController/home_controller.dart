// lib/features/home/controllers/home_controller.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/home_model.dart';
import '../../courses/models/course_model.dart';
import '../../articles/models/article_model.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  var banners = <BannerModel>[].obs;
  Rxn<UserProfileModel> userProfile = Rxn<UserProfileModel>();
  var latestCourses = <CourseModel>[].obs;
  var latestArticles = <ArticleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading(true);
      errorMessage('');

      // استفاده از ApiClient متمرکز که توکن را به طور خودکار ارسال می‌کند
      final response = await ApiClient().dio.get('core/home/');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['banners'] != null) {
          banners.value = (data['banners'] as List).map((b) => BannerModel.fromJson(b)).toList();
        }
        if (data['user'] != null) {
          userProfile.value = UserProfileModel.fromJson(data['user']);
        }
        if (data['latest_courses'] != null) {
          latestCourses.value = (data['latest_courses'] as List).map((c) => CourseModel.fromJson(c)).toList();
        }
        if (data['latest_articles'] != null) {
          latestArticles.value = (data['latest_articles'] as List).map((a) => ArticleModel.fromJson(a)).toList();
        }
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        errorMessage('درخواست‌های شما بیش از حد مجاز است. لطفاً چند لحظه صبر کنید.');
      } else {
        errorMessage('خطا در ارتباط با سرور. لطفاً اتصال خود را بررسی کنید.');
      }
    } finally {
      isLoading(false);
    }
  }
}