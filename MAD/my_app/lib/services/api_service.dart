import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import 'preference_service.dart';

class ApiService {
  static const String _apiUrl = 'https://fakestoreapi.com/products';

  static Future<List<CourseModel>> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Cache the raw JSON locally
        await PreferenceService.cacheCoursesJson(response.body);

        return data.map((json) => CourseModel.fromJson(json)).toList();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      // Offline fallback: load from SharedPreferences cache
      final cachedJson = PreferenceService.getCachedCoursesJson();
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final List<dynamic> data = json.decode(cachedJson);
          return data.map((json) => CourseModel.fromJson(json)).toList();
        } catch (_) {}
      }
      
      // If no cache, fall back to robust mock courses
      return _getMockCourses();
    }
  }

  static List<CourseModel> _getMockCourses() {
    return [
      CourseModel(
        id: 'mock-1',
        title: 'Mastering Flutter & Dart for Mobile Dev',
        instructor: 'Dr. Angela Yu',
        description: 'Build beautiful, native iOS and Android apps with a single codebase. Complete guide from beginner to expert.',
        rating: 4.8,
        thumbnail: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=600&auto=format&fit=crop',
        price: 99.99,
        isFree: false,
        isPopular: true,
        lessons: [],
      ),
      CourseModel(
        id: 'mock-2',
        title: 'Introduction to Python Programming',
        instructor: 'Professor Charles Severance',
        description: 'Learn Python basics, data structures, database design, and data visualization. No prior coding experience required.',
        rating: 4.6,
        thumbnail: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?q=80&w=600&auto=format&fit=crop',
        price: 0.0,
        isFree: true,
        isPopular: false,
        lessons: [],
      ),
      CourseModel(
        id: 'mock-3',
        title: 'Full-Stack Web Development Bootcamp',
        instructor: 'Colt Steele',
        description: 'The only course you need to learn Web Development: HTML, CSS, JS, Node, React, MongoDB, and more!',
        rating: 4.9,
        thumbnail: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=600&auto=format&fit=crop',
        price: 129.99,
        isFree: false,
        isPopular: true,
        lessons: [],
      ),
      CourseModel(
        id: 'mock-4',
        title: 'UX/UI Design Fundamentals',
        instructor: 'Sarah Jenkins',
        description: 'Learn modern Figma techniques, user research, wireframing, prototyping, and layout principles to design stunning apps.',
        rating: 4.4,
        thumbnail: 'https://images.unsplash.com/photo-1586717791821-3f44a563fa4c?q=80&w=600&auto=format&fit=crop',
        price: 0.0,
        isFree: true,
        isPopular: true,
        lessons: [],
      ),
    ];
  }
}
