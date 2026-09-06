// lib/features/subscriptions/screens/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';
import '../models/subscription_model.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تزریق کنترلر به صفحه
    final SubscriptionController controller = Get.put(SubscriptionController());

    final Color darkBg = const Color(0xFF0F1115);
    final Color surfaceColor = const Color(0xFF161A22);
    final Color primaryOrange = const Color(0xFFFF8C00);
    final Color textMuted = const Color(0xFF94A3B8);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: _buildAppBar(context, primaryOrange, darkBg),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: primaryOrange));
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value, style: TextStyle(color: textMuted)));
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  _buildHeader(textMuted),
                  const SizedBox(height: 32),
                  if (controller.plans.isEmpty)
                    Text('پلنی برای نمایش وجود ندارد.', style: TextStyle(color: textMuted))
                  else
                    ...controller.plans.map((plan) => _buildPlanCard(controller, plan, surfaceColor, primaryOrange, textMuted)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Color primaryOrange, Color darkBg) {
    return AppBar(
      backgroundColor: darkBg,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'خرید اشتراک ویژه',
        style: TextStyle(color: primaryOrange, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildHeader(Color textMuted) {
    return Column(
      children: [
        const Text(
          'ارتقای حساب کاربری',
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'با خرید اشتراک، به تمامی امکانات پیشرفته و دوره‌ها دسترسی کامل داشته باشید.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textMuted, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    SubscriptionController controller,
    SubscriptionPlanModel plan,
    Color surfaceColor,
    Color primaryOrange,
    Color textMuted,
  ) {
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
                color: isPopular ? primaryOrange : Colors.white.withValues(alpha: 0.05),
                width: isPopular ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                      '${plan.price} تومان',
                      style: TextStyle(color: primaryOrange, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text('(${plan.durationDays} روزه)', style: TextStyle(color: textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  // مدیریت هوشمند کلیک: اگر در حال خرید هستیم، دکمه غیرفعال می‌شود
                  child: ElevatedButton(
                    onPressed: controller.isBuying.value ? null : () => controller.buyPlan(plan.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Obx(() {
                      return controller.isBuying.value
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'انتخاب و خرید پلن',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            );
                    }),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(6)),
                child: const Text(
                  'پیشنهاد ویژه',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}