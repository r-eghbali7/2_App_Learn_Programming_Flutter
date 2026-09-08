// lib/features/profile/screens/my_certificates_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

// === مدل داده مدارک ===
class CertificateModel {
  final String certId;
  final String courseTitle;
  final String imageUrl;

  CertificateModel({
    required this.certId,
    required this.courseTitle,
    required this.imageUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      certId: json['cert_id'] ?? '',
      courseTitle: json['course_title'] ?? 'دوره آموزشی',
      imageUrl: json['image'] ?? '',
    );
  }
}

// === کنترلر مدارک ===
class CertificateController extends GetxController {
  var isLoading = true.obs;
  var certificates = <CertificateModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await ApiClient().dio.get(
        'courses/list/my-certificates/',
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        certificates.value = data
            .map((c) => CertificateModel.fromJson(c))
            .toList();
      }
    } catch (e) {
      errorMessage('خطا در دریافت لیست مدارک.');
    } finally {
      isLoading(false);
    }
  }

  // متد باز کردن لینک عکس در مرورگر گوشی برای دانلود
  Future<void> downloadCertificate(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'خطا',
        'امکان باز کردن فایل وجود ندارد.',
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
      );
    }
  }
}

// === صفحه نمایش مدارک (UI) ===
class MyCertificatesScreen extends StatelessWidget {
  const MyCertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CertificateController controller = Get.put(CertificateController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'مدارک من',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          if (controller.certificates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'شما هنوز مدرکی دریافت نکرده‌اید.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: controller.certificates.length,
            itemBuilder: (context, index) {
              final cert = controller.certificates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert.courseTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'شماره: ${cert.certId}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          controller.downloadCertificate(cert.imageUrl),
                      icon: const Icon(
                        Icons.download_rounded,
                        color: AppColors.primaryOrange,
                      ),
                      tooltip: 'دانلود',
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
