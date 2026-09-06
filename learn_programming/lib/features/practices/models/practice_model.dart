class PracticeModel {
  final int id;
  final String title;
  final String language;
  final String starterCode;

  PracticeModel({
    required this.id,
    required this.title,
    required this.language,
    required this.starterCode,
  });

  factory PracticeModel.fromJson(Map<String, dynamic> json) {
    return PracticeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'تست الگوریتم',
      language: json['language'] ?? 'JS',
      starterCode: json['starter_code'] ?? '// کدهای خود را اینجا بنویسید',
    );
  }
}