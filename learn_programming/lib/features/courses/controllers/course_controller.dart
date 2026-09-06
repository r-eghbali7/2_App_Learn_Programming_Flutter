// lib/features/courses/controllers/my_courses_controller.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/course_model.dart';


class CourseController extends GetxController {
  // متغیرهای وضعیت (State) که UI به آنها گوش می‌دهد
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var coursesList = <CourseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      isLoading(true);
      errorMessage('');
      
      // استفاده از سرویس متمرکزی که ساختیم (نیازی به ذکر BaseUrl نیست)
      final response = await ApiClient().dio.get('courses/list/');

      if (response.statusCode == 200) {
        // نکته: در بک‌اند Pagination را فعال کردیم، پس دیتا داخل کلید 'results' است
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
}



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