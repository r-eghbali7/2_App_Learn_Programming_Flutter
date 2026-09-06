class BannerModel {
  final int id;
  final String title;
  final String? imageUrl;
  final String? link;

  BannerModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.link,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      imageUrl: json['image'], // منطبق بر فیلد image در BannerSerializer
      link: json['link'],
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