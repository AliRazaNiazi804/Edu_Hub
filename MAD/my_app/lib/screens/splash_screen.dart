import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/preference_service.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Only initialize notifications on non-web platforms
      if (!identical(0, 0.0)) { // Pure Dart check or we can import foundation
        // But kIsWeb is standard. Let's make sure it is safe.
      }
      
      // Let's use try-catch safely.
      await _initNotificationSafety();
    } catch (e) {
      debugPrint('Error initializing notification services: $e');
    }

    // Hold the splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check auth token for automatic redirection
    final token = PreferenceService.getToken();
    if (token != null && token.isNotEmpty) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  Future<void> _initNotificationSafety() async {
    // Only attempt on mobile / desktop platforms that support it
    try {
      await NotificationService.init();
      await NotificationService.requestPermissions();

      if (PreferenceService.areNotificationsEnabled()) {
        await NotificationService.scheduleDailyReminder();
      }
    } catch (e) {
      debugPrint('Notification plugin is not supported on this platform: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primaryContainer,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 100,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 24),
            Text(
              'EduHub',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Online Learning Platform',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
