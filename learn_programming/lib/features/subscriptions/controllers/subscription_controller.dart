// lib/features/subscriptions/controllers/subscription_controller.dart
import 'dart:async';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import '../../../core/network/api_client.dart';
import '../models/subscription_model.dart';

class SubscriptionController extends GetxController {
  var isLoading = true.obs;
  var isBuying = false.obs;
  var plans = <SubscriptionPlanModel>[].obs;
  var errorMessage = ''.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
    _initDeepLinkListener(); // فعال‌سازی لیسنر هنگام ورود به صفحه
  }

  @override
  void onClose() {
    _sub?.cancel(); // حتماً لیسنر را هنگام خروج ببندید تا مموری لیک نشود
    super.onClose();
  }

  // === دریافت پلن‌ها ===
  Future<void> fetchPlans() async {
    try {
      isLoading(true);
      final response = await ApiClient().dio.get('subscriptions/plans/');
      
      if (response.statusCode == 200) {
        final List data = response.data['results'] ?? response.data;
        plans.value = data.map((p) => SubscriptionPlanModel.fromJson(p)).toList();
      }
    } catch (e) {
      errorMessage('خطا در دریافت لیست اشتراک‌ها.');
    } finally {
      isLoading(false);
    }
  }

  // === مرحله اول پرداخت: دریافت لینک از بک‌اند و باز کردن مرورگر ===
  Future<void> buyPlan(int planId) async {
    try {
      isBuying(true);
      // ارسال درخواست به ویوی PaymentRequestView در جنگو
      final response = await ApiClient().dio.post(
        'subscriptions/request-payment/',
        data: {'plan_id': planId},
      );

      if (response.statusCode == 200 && response.data['payment_url'] != null) {
        final String url = response.data['payment_url'];
        final Uri paymentUri = Uri.parse(url);
        
        // باز کردن مرورگر پیش‌فرض گوشی (کروم یا سافاری)
        if (await canLaunchUrl(paymentUri)) {
          await launchUrl(paymentUri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('خطا', 'امکان باز کردن مرورگر وجود ندارد.', backgroundColor: Get.theme.primaryColor);
        }
      }
    } catch (e) {
      Get.snackbar('خطا', 'مشکلی در اتصال به درگاه پرداخت پیش آمد.', backgroundColor: Get.theme.colorScheme.error);
    } finally {
      isBuying(false);
    }
  }

  // === مرحله دوم پرداخت: گوش دادن به بازگشت کاربر از درگاه ===
  void _initDeepLinkListener() {
    // گوش دادن به لینک‌هایی که از بیرون اپلیکیشن باز می‌شوند
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleIncomingLink(link);
      }
    }, onError: (err) {
      print('Deep Link Error: $err');
    });
  }

  void _handleIncomingLink(String link) {
    final Uri uri = Uri.parse(link);
    
    // اگر Scheme و Host دقیقاً همانی باشد که در اندروید مانیفست دادیم
    if (uri.scheme == 'codeglass' && uri.host == 'payment-success') {
      final String? refId = uri.queryParameters['ref_id'];
      
      if (refId != null && refId.isNotEmpty) {
        // پرداخت موفق بوده است!
        Get.defaultDialog(
          title: 'پرداخت موفق',
          middleText: 'اشتراک شما با شماره پیگیری $refId فعال شد.',
          textConfirm: 'متوجه شدم',
          confirmTextColor: const Color(0xFFFFFFFF),
          buttonColor: const Color(0xFF34D399),
          onConfirm: () {
            Get.back(); // بستن دیالوگ
            Get.back(); // بازگشت به صفحه پروفایل
          },
        );
      }
    }
  }
}