// lib/features/subscriptions/screens/purchases_screen.dart
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  bool _isLoading = true;
  List<dynamic> _purchases = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // اندپوینتی که در جنگو برای تاریخچه تراکنش‌ها/خریدهای کاربر ساخته‌اید
      final response = await ApiClient().dio.get('subscriptions/my-purchases/');

      if (response.statusCode == 200) {
        setState(() {
          _purchases = response.data['results'] ?? response.data;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطا در دریافت تاریخچه خریدها.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        appBar: AppBar(
          backgroundColor: AppColors.darkBg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تاریخچه خریدهای من',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryOrange))
            : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage, style: TextStyle(color: AppColors.textMuted)))
                : _purchases.isEmpty
                    ? Center(
                        child: Text(
                          'هنوز هیچ خریدی ثبت نکرده‌اید.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: _purchases.length,
                        itemBuilder: (context, index) {
                          final item = _purchases[index];
                          final bool isSuccess = item['status'] == 'success';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['plan_title'] ?? 'اشتراک ویژه',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'کد پیگیری: ${item['ref_id'] ?? 'نامشخص'}',
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'مبلغ: ${item['amount']} تومان',
                                      style: TextStyle(color: AppColors.primaryOrange, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (isSuccess ? AppColors.successGreen : AppColors.errorRed).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: isSuccess ? AppColors.successGreen : AppColors.errorRed),
                                  ),
                                  child: Text(
                                    isSuccess ? 'موفق' : 'ناموفق',
                                    style: TextStyle(
                                      color: isSuccess ? AppColors.successGreen : AppColors.errorRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}