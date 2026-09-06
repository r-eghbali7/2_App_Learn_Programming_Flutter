class SubscriptionPlanModel {
  final int id;
  final String title;
  final int durationDays;
  final int price;
  final String description;

  SubscriptionPlanModel({
    required this.id,
    required this.title,
    required this.durationDays,
    required this.price,
    required this.description,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'پلن اشتراک',
      durationDays: json['duration_days'] ?? 30,
      price: json['price'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}