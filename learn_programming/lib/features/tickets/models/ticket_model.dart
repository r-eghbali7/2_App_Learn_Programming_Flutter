class TicketModel {
  final int id;
  final String subject;
  final String subjectDisplay;
  final String message;
  final String status;
  final String statusDisplay;
  final String? attachmentUrl;
  final String createdAt;

  TicketModel({
    required this.id,
    required this.subject,
    required this.subjectDisplay,
    required this.message,
    required this.status,
    required this.statusDisplay,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      subjectDisplay: json['subject_display'] ?? 'سایر موارد',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      statusDisplay: json['status_display'] ?? 'در حال بررسی',
      attachmentUrl: json['attachment'], // آدرس فایل ضمیمه دریافتی از سرور
      createdAt: json['created_at'] ?? '',
    );
  }
}