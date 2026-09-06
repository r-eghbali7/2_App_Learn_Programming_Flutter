class ProfileModel {
  final String fullName;
  final String email; // یا شماره موبایل
  final String avatarUrl;
  final int streakDays;
  final bool isProUser;

  ProfileModel({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.streakDays,
    required this.isProUser,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['full_name'] ?? 'کاربر دوفلو',
      // اگر ایمیل نبود، شماره موبایل را نشان می‌دهیم
      email: json['email'] ?? json['phone_number'] ?? '', 
      avatarUrl: json['avatar'] ?? 'assets/images/avatar_large.jpg',
      streakDays: json['streak_days'] ?? 14, // مقدار پیش‌فرض روند
      isProUser: json['is_pro'] ?? true, // وضعیت کاربر حرفه‌ای
    );
  }
}