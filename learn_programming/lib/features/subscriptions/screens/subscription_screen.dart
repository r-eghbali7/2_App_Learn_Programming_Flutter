import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/subscription_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  List<SubscriptionPlanModel> _plans = [];
  bool _isBuying = false;

  final Color darkBg = const Color(0xFF0F1115);
  final Color surfaceColor = const Color(0xFF161A22);
  final Color primaryOrange = const Color(0xFFFF8C00);
  final Color textMuted = const Color(0xFF94A3B8);
  final Color successGreen = const Color(0xFF34D399);

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final dio = Dio();
      // استفاده از 127.0.0.1 برای کروم
      final response = await dio.get(
        'http://127.0.0.1:8000/api/subscriptions/plans/',
      );

      if (response.statusCode == 200) {
        setState(() {
          _plans = (response.data as List)
              .map((p) => SubscriptionPlanModel.fromJson(p))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Subscription Plans Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buyPlan(int planId) async {
    setState(() => _isBuying = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      await dio.post(
        'http://127.0.0.1:8000/api/subscriptions/my/mock_buy/',
        data: {'plan_id': planId},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اشتراک شما با موفقیت فعال شد!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در خرید اشتراک.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: _buildAppBar(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      if (_plans.isEmpty)
                        Text(
                          'پلنی برای نمایش وجود ندارد.',
                          style: TextStyle(color: textMuted),
                        )
                      else
                        ..._plans.map((plan) => _buildPlanCard(plan)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'خرید اشتراک ویژه',
        style: TextStyle(
          color: primaryOrange,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'ارتقای حساب کاربری',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'با خرید اشتراک، به تمامی امکانات پیشرفته، دوره‌ها و قابلیت‌های هوش مصنوعی دسترسی کامل داشته باشید.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlanModel plan) {
    // پلن آخر یا سوم را به عنوان محبوب‌ترین در نظر می‌گیریم (یا شرط دلخواه)
    final bool isPopular = plan.durationDays > 180 || plan.id == 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPopular
                    ? primaryOrange
                    : Colors.white.withValues(alpha: 0.05),
                width: isPopular ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${plan.price} ریال',
                      style: TextStyle(
                        color: primaryOrange,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${plan.durationDays} روزه)',
                      style: TextStyle(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isBuying ? null : () => _buyPlan(plan.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isBuying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'انتخاب و خرید پلن',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -12,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'پیشنهاد ویژه',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
