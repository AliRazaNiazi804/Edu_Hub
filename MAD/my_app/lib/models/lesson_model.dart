class LessonModel {
  final String id;
  final String title;
  final String duration;

  LessonModel({
    required this.id,
    required this.title,
    required this.duration,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '10:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
    };
  }
}
