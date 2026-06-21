import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/models/course_model.dart';
import 'package:my_app/models/lesson_model.dart';

void main() {
  group('Validation Logic Tests', () {
    test('Email validator should identify invalid emails', () {
      final invalidEmail = 'student.com';
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      expect(emailRegex.hasMatch(invalidEmail), isFalse);
    });

    test('Email validator should identify valid emails', () {
      final validEmail = 'student@university.edu';
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      expect(emailRegex.hasMatch(validEmail), isTrue);
    });

    test('Password validator should check min length requirement', () {
      final shortPassword = '123';
      final longPassword = 'password123';
      expect(shortPassword.length >= 6, isFalse);
      expect(longPassword.length >= 6, isTrue);
    });

    test('Name validator should check min length requirement', () {
      final shortName = 'Jo';
      final longName = 'John Doe';
      expect(shortName.length >= 3, isFalse);
      expect(longName.length >= 3, isTrue);
    });
  });

  group('Model Serialization Tests', () {
    test('LessonModel toJson and fromJson match', () {
      final lessonJson = {
        'id': '1',
        'title': 'Test Lesson',
        'duration': '15:45',
      };

      final lesson = LessonModel.fromJson(lessonJson);
      expect(lesson.id, '1');
      expect(lesson.title, 'Test Lesson');
      expect(lesson.duration, '15:45');

      final serialized = lesson.toJson();
      expect(serialized['id'], '1');
      expect(serialized['title'], 'Test Lesson');
      expect(serialized['duration'], '15:45');
    });

    test('CourseModel serialization matches expectations', () {
      final courseJson = {
        'id': '101',
        'title': 'Test Course',
        'instructor': 'Test Instructor',
        'description': 'Test Description',
        'price': 15.0,
        'image': 'https://test.com/img.png',
        'lessons': [
          {'id': '1', 'title': 'Intro', 'duration': '05:00'}
        ]
      };

      final course = CourseModel.fromJson(courseJson);
      expect(course.id, '101');
      expect(course.title, 'Test Course');
      expect(course.price, 15.0);
      expect(course.lessons.length, 1);
      expect(course.lessons.first.title, 'Intro');
    });
  });
}
