import 'dart:async'; // === برای استفاده از Timer اضافه شد ===
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/course_model.dart';

class CourseController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var coursesList = <CourseModel>[].obs;

  // === تایمر برای جلوگیری از ارسال اسپم درخواست‌ها (Debounce) ===
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  // === متد دریافت دوره‌ها تغییر کرد تا کوئری جستجو را بپذیرد ===
  Future<void> fetchCourses({String? query}) async {
    try {
      isLoading(true);
      errorMessage('');
      
      // ساخت آدرس به صورت داینامیک
      String endpoint = 'courses/list/';
      if (query != null && query.isNotEmpty) {
        endpoint += '?search=$query'; // ارسال پارامتر جستجو به جنگو
      }

      final response = await ApiClient().dio.get(endpoint);

      if (response.statusCode == 200) {
        final List data = response.data['results'] ?? response.data;
        coursesList.value = data.map((c) => CourseModel.fromJson(c)).toList();
      }
    } catch (e) {
      if (e is DioException) {
        errorMessage('خطا در ارتباط با سرور.');
      } else {
        errorMessage('خطای ناشناخته رخ داده است.');
      }
    } finally {
      isLoading(false);
    }
  }

  // === متد جدید برای وصل شدن به فیلد جستجو ===
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // صبر می‌کنیم تا کاربر ۵۰۰ میلی‌ثانیه تایپ نکند، سپس درخواست می‌زنیم
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) {
        fetchCourses(query: query); // جستجو برای ۳ حرف یا بیشتر
      } else if (query.isEmpty) {
        fetchCourses(); // اگر فیلد خالی شد، همه دوره‌ها را دوباره لود کن
      }
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}

// ... کلاس MyCoursesController بدون تغییر می‌ماند

class MyCoursesController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var myCoursesList = <MyCourseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyCourses();
  }

  Future<void> fetchMyCourses() async {
    try {
      isLoading(true);
      errorMessage('');
      
      // فراخوانی اندپوینت اختصاصی که در جنگو ساختیم
      // نکته: نیازی به پاس دادن دستی Token نیست، ApiClient خودش انجام می‌دهد.
      final response = await ApiClient().dio.get('courses/list/my-courses/');

      if (response.statusCode == 200) {
        // این اندپوینت چون با action نوشته شده بود و مستقیماً لیست را برمی‌گرداند (بدون Pagination)
        final List data = response.data;
        myCoursesList.value = data.map((c) => MyCourseModel.fromJson(c)).toList();
      }
    } catch (e) {
      if (e is DioException) {
        errorMessage('خطا در برقراری ارتباط. لطفاً اتصال خود را بررسی کنید.');
      } else {
        errorMessage('خطایی در دریافت دوره‌های شما رخ داد.');
      }
    } finally {
      isLoading(false);
    }
  }
}