// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' as getx;
import '../../features/auth/screens/login_screen.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  // جلوگیری از اجرای همزمان چند درخواست رفرش توکن
  bool _isRefreshing = false;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api/';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // === مرحله ۱: اضافه کردن توکن به درخواست‌ها ===
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        
        // === مرحله ۲: هندل کردن خطای 401 و تمدید توکن ===
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            
            // اگر خود درخواستِ رفرش توکن ارور 401 داد، یعنی رفرش توکن هم باطل شده است
            // پس مستقیماً کاربر را خارج می‌کنیم تا لوپ بی‌نهایت نسازیم.
            if (e.requestOptions.path.contains('token/refresh/')) {
              _logoutUser();
              return handler.next(e);
            }

            // اگر در حال حاضر یک درخواست دیگر در حال تمدید توکن نیست
            if (!_isRefreshing) {
              _isRefreshing = true;
              
              final isRefreshed = await _refreshToken();
              
              _isRefreshing = false;

              if (isRefreshed) {
                // توکن با موفقیت تمدید شد! حالا درخواست شکست‌خورده را دوباره می‌فرستیم
                return _retryOriginalRequest(e.requestOptions, handler);
              } else {
                // تمدید توکن ناموفق بود (احتمالاً Refresh Token هم منقضی شده)
                _logoutUser();
                return handler.next(e);
              }
            }
          }
          
          // اگر ارور 401 نبود یا مربوط به چیز دیگری بود، ارور را به UI پاس می‌دهیم
          return handler.next(e);
        },
      ),
    );
  }

  // === متد کمکی برای گرفتن توکن جدید ===
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://127.0.0.1:8000/api/';

      if (refreshToken == null) return false;

      // یک Dio مستقل می‌سازیم که Interceptor نداشته باشد تا در لوپ نیفتد
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      
      final response = await refreshDio.post(
        'accounts/token/refresh/', // اندپوینتی که در جنگو ساختیم
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        // ذخیره Access Token جدید
        final newAccessToken = response.data['access'];
        await prefs.setString('access_token', newAccessToken);
        
        // اگر سرور Refresh Token جدید هم فرستاد، آن را آپدیت می‌کنیم
        if (response.data['refresh'] != null) {
          await prefs.setString('refresh_token', response.data['refresh']);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // === متد کمکی برای اجرای مجدد درخواست شکست‌خورده ===
  Future<void> _retryOriginalRequest(RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newToken = prefs.getString('access_token');
      
      // هدر درخواست قبلی را با توکن جدید آپدیت می‌کنیم
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
      
      // درخواست را با یک دیو جدید (بدون اینترسپتور) تکرار می‌کنیم
      final retryDio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
      final response = await retryDio.fetch(requestOptions);
      
      // نتیجه موفقیت‌آمیز را به کلاسی که منتظر پاسخ بود برمی‌گردانیم
      return handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        return handler.next(e);
      }
    }
  }

  // === خروج کاربر ===
  void _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // پاک کردن توکن‌ها
    
    getx.Get.snackbar(
      'پایان نشست',
      'مدت زمان ورود شما به پایان رسیده است. لطفاً مجدداً وارد شوید.',
      snackPosition: getx.SnackPosition.BOTTOM,
    );
    
    // هدایت به صفحه ورود و پاک کردن تاریخچه صفحات
    getx.Get.offAll(() => const LoginScreen());
  }
}