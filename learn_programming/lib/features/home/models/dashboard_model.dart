class ChangeModel {
  final String title;
  final String subtitle;
  final String status;
  final int statusColor;
  final int iconCodePoint; // برای ذخیره کد آیکون
  final int iconBg;
  final int iconColor;

  ChangeModel({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.iconCodePoint,
    required this.iconBg,
    required this.iconColor,
  });

  factory ChangeModel.fromJson(Map<String, dynamic> json) {
    return ChangeModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      status: json['status'] ?? '',
      statusColor: json['status_color'] ?? 0xFF475569, // پیش‌فرض خاکستری
      iconCodePoint: json['icon_code'] ?? 0xe16a, // یک آیکون پیش‌فرض
      iconBg: json['icon_bg'] ?? 0xFF2E1065,
      iconColor: json['icon_color'] ?? 0xFFA78BFA,
    );
  }
}

class DashboardModel {
  final int activeProjects;
  final int openReviews;
  final List<ChangeModel> latestChanges;

  DashboardModel({
    required this.activeProjects,
    required this.openReviews,
    required this.latestChanges,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      activeProjects: json['active_projects'] ?? 0,
      openReviews: json['open_reviews'] ?? 0,
      latestChanges:
          (json['latest_changes'] as List?)
              ?.map((e) => ChangeModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
