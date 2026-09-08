class BannerModel {
  final int id;
  final String title;
  final String? imageUrl;
  final int? courseId; // شناسه دوره مرتبط با بنر

  BannerModel({required this.id, required this.title, this.imageUrl, this.courseId});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image'] ?? json['image_url'],
      courseId: json['course'] ?? json['course_id'], // تطبیق با کلید خروجی جنگو
    );
  }
}

class UserProfileModel {
  final int id;
  final String phoneNumber;
  final String fullName;

  UserProfileModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      fullName: json['full_name'] ?? 'کاربر گرامی',
    );
  }
}