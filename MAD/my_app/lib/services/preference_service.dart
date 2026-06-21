import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  static Future<bool> setToken(String token) async {
    return await _prefs?.setString('auth_token', token) ?? false;
  }

  static String? getToken() {
    return _prefs?.getString('auth_token');
  }

  static Future<bool> clearToken() async {
    return await _prefs?.remove('auth_token') ?? false;
  }

  // Theme Mode
  static Future<bool> setDarkMode(bool isDark) async {
    return await _prefs?.setBool('is_dark_mode', isDark) ?? false;
  }

  static bool isDarkMode() {
    return _prefs?.getBool('is_dark_mode') ?? false;
  }

  // Favorites
  static Future<bool> setFavorites(Set<String> favIds) async {
    return await _prefs?.setStringList('favorite_courses', favIds.toList()) ?? false;
  }

  static Set<String> getFavorites() {
    return _prefs?.getStringList('favorite_courses')?.toSet() ?? {};
  }

  static Future<bool> toggleFavorite(String courseId) async {
    final favs = getFavorites();
    if (favs.contains(courseId)) {
      favs.remove(courseId);
    } else {
      favs.add(courseId);
    }
    return await setFavorites(favs);
  }

  // User Profile
  static Future<bool> setUserName(String name) async {
    return await _prefs?.setString('user_name', name) ?? false;
  }

  static String getUserName() {
    return _prefs?.getString('user_name') ?? 'University Student';
  }

  static Future<bool> setUserEmail(String email) async {
    return await _prefs?.setString('user_email', email) ?? false;
  }

  static String getUserEmail() {
    return _prefs?.getString('user_email') ?? 'student@university.edu';
  }

  // Daily Reminder Notifications
  static Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs?.setBool('notifications_enabled', enabled) ?? true;
  }

  static bool areNotificationsEnabled() {
    return _prefs?.getBool('notifications_enabled') ?? true;
  }

  static Future<bool> setReminderTime(String timeStr) async {
    return await _prefs?.setString('reminder_time', timeStr) ?? false;
  }

  static String getReminderTime() {
    return _prefs?.getString('reminder_time') ?? '09:00';
  }

  // Offline Courses Cache
  static Future<bool> cacheCoursesJson(String jsonStr) async {
    return await _prefs?.setString('cached_courses_json', jsonStr) ?? false;
  }

  static String? getCachedCoursesJson() {
    return _prefs?.getString('cached_courses_json');
  }
}
