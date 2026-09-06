class CourseModel {
  final int id;
  final String title;
  final String? thumbnail;
  final String instructor;

  CourseModel({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.instructor,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'بدون عنوان',
      thumbnail: json['thumbnail'], // منطبق با کلید thumbnail در API
      instructor: json['instructor'] ?? 'مدرس نامشخص',
    );
  }
}

class LessonModel {
  final int id;
  final String title;
  final String? content;
  final String videoUrl;
  final int order;
  final bool isCompleted;
  final String? userNote;

  LessonModel({
    required this.id,
    required this.title,
    this.content,
    required this.videoUrl,
    required this.order,
    required this.isCompleted,
    this.userNote,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'],
      videoUrl: json['video_url'] ?? '',
      order: json['order'] ?? 1,
      isCompleted: json['is_completed'] ?? false,
      userNote: json['user_note'],
    );
  }
}

class CourseDetailModel {
  final int id;
  final String title;
  final String? description;
  final String? thumbnail;
  final String instructor;
  final int progressPercentage;
  final List<LessonModel> lessons;

  CourseDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    required this.instructor,
    required this.progressPercentage,
    required this.lessons,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'],
      instructor: json['instructor'] ?? '',
      progressPercentage: json['progress_percentage'] ?? 0,
      lessons: (json['lessons'] as List?)?.map((l) => LessonModel.fromJson(l)).toList() ?? [],
    );
  }
}

class MyCourseModel {
  final int id;
  final String title;
  final String description;
  final double progress;
  final String modulesText;
  final String status;
  final bool isCompleted;

  MyCourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.modulesText,
    required this.status,
    required this.isCompleted,
  });

  factory MyCourseModel.fromJson(Map<String, dynamic> json) {
    return MyCourseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      modulesText: json['modules_text'] ?? '',
      status: json['status'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }
}