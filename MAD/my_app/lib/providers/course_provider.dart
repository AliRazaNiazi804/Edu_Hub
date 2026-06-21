import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

enum CourseFilter { all, free, popular }

class CourseProvider extends ChangeNotifier {
  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  CourseFilter _selectedFilter = CourseFilter.all;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  CourseFilter get selectedFilter => _selectedFilter;

  // Filtered courses based on search query and filter chips
  List<CourseModel> get filteredCourses {
    return _courses.where((course) {
      final matchesSearch = course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.instructor.toLowerCase().contains(_searchQuery.toLowerCase());
      
      switch (_selectedFilter) {
        case CourseFilter.free:
          return matchesSearch && course.isFree;
        case CourseFilter.popular:
          return matchesSearch && course.isPopular;
        case CourseFilter.all:
          return matchesSearch;
      }
    }).toList();
  }

  // Load / Refresh courses
  Future<void> loadCourses({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
    }

    try {
      _courses = await ApiService.fetchCourses();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(CourseFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
