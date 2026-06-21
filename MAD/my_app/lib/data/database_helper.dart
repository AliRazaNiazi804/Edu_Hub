import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Web in-memory fallbacks
  final List<Map<String, dynamic>> _webEnrolledCourses = [];
  final List<Map<String, dynamic>> _webWatchedLessons = [];

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('eduhub.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // enrolled_courses table
    await db.execute('''
      CREATE TABLE enrolled_courses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        instructor TEXT NOT NULL,
        enrolledDate TEXT NOT NULL,
        progressPercent REAL NOT NULL
      )
    ''');

    // watched_lessons table
    await db.execute('''
      CREATE TABLE watched_lessons (
        lessonId TEXT PRIMARY KEY,
        courseId TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Insert Enrolled Course
  Future<int> insertEnrolledCourse(Map<String, dynamic> course) async {
    if (kIsWeb) {
      _webEnrolledCourses.removeWhere((item) => item['id'] == course['id']);
      _webEnrolledCourses.add(course);
      return 1;
    }
    final db = await instance.database;
    return await db.insert(
      'enrolled_courses',
      course,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get Enrolled Courses
  Future<List<Map<String, dynamic>>> getEnrolledCourses() async {
    if (kIsWeb) {
      return List.from(_webEnrolledCourses);
    }
    final db = await instance.database;
    return await db.query('enrolled_courses');
  }

  // Update Course Progress
  Future<int> updateProgress(String courseId, double progressPercent) async {
    if (kIsWeb) {
      for (var i = 0; i < _webEnrolledCourses.length; i++) {
        if (_webEnrolledCourses[i]['id'] == courseId) {
          final updated = Map<String, dynamic>.from(_webEnrolledCourses[i]);
          updated['progressPercent'] = progressPercent;
          _webEnrolledCourses[i] = updated;
          break;
        }
      }
      return 1;
    }
    final db = await instance.database;
    return await db.update(
      'enrolled_courses',
      {'progressPercent': progressPercent},
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  // Delete Enrolled Course
  Future<int> deleteEnrolledCourse(String courseId) async {
    if (kIsWeb) {
      _webEnrolledCourses.removeWhere((item) => item['id'] == courseId);
      return 1;
    }
    final db = await instance.database;
    return await db.delete(
      'enrolled_courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );
  }

  // Check if course is enrolled
  Future<bool> isEnrolled(String courseId) async {
    if (kIsWeb) {
      return _webEnrolledCourses.any((item) => item['id'] == courseId);
    }
    final db = await instance.database;
    final maps = await db.query(
      'enrolled_courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );
    return maps.isNotEmpty;
  }

  // Mark Lesson as Watched
  Future<int> markLessonWatched(String lessonId, String courseId) async {
    if (kIsWeb) {
      _webWatchedLessons.removeWhere((item) => item['lessonId'] == lessonId);
      _webWatchedLessons.add({
        'lessonId': lessonId,
        'courseId': courseId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return 1;
    }
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    return await db.insert(
      'watched_lessons',
      {
        'lessonId': lessonId,
        'courseId': courseId,
        'timestamp': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get Watched Lessons for a Course
  Future<List<Map<String, dynamic>>> getWatchedLessons(String courseId) async {
    if (kIsWeb) {
      return _webWatchedLessons.where((item) => item['courseId'] == courseId).toList();
    }
    final db = await instance.database;
    return await db.query(
      'watched_lessons',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
  }

  // Clear Database (for testing / reset)
  Future<void> clearAll() async {
    if (kIsWeb) {
      _webEnrolledCourses.clear();
      _webWatchedLessons.clear();
      return;
    }
    final db = await instance.database;
    await db.delete('enrolled_courses');
    await db.delete('watched_lessons');
  }
}
