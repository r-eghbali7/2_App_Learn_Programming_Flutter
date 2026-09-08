// lib/features/profile/controllers/profile_controller.dart
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/profile_model.dart';

class ProfileController extends GetxController {
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  Rxn<ProfileModel> userData = Rxn<ProfileModel>();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoading(true);
      errorMessage('');

      // استفاده از ApiClient مرکزی برای ارسال اتوماتیک توکن کاربر
      final response = await ApiClient().dio.get('core/profile/');

      if (response.statusCode == 200) {
        userData.value = ProfileModel.fromJson(response.data);
      }
    } catch (e) {
      if (e is DioException) {
        errorMessage('خطا در دریافت اطلاعات پروفایل از سرور.');
      } else {
        errorMessage('خطای ناشناخته رخ داد.');
      }
    } finally {
      isLoading(false);
    }
  }
}