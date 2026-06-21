import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/theme_provider.dart';
import '../services/preference_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _notificationsEnabled = true;
  String _reminderTime = '09:00';

  @override
  void initState() {
    super.initState();
    _nameController.text = PreferenceService.getUserName();
    _emailController.text = PreferenceService.getUserEmail();
    _notificationsEnabled = PreferenceService.areNotificationsEnabled();
    _reminderTime = PreferenceService.getReminderTime();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await PreferenceService.setUserName(_nameController.text.trim());
    await PreferenceService.setUserEmail(_emailController.text.trim());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _selectTime() async {
    final parts = _reminderTime.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 9;
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      final timeStr = '$hourStr:$minuteStr';

      await PreferenceService.setReminderTime(timeStr);
      setState(() {
        _reminderTime = timeStr;
      });

      // Reschedule the notification reminder with the new time
      await NotificationService.scheduleDailyReminder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Daily reminder scheduled for $_reminderTime')),
        );
      }
    }
  }

  void _toggleNotifications(bool value) async {
    await PreferenceService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (value) {
      await NotificationService.scheduleDailyReminder();
    } else {
      await NotificationService.cancelAll();
    }
  }

  void _logout() async {
    await PreferenceService.clearToken();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'S',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameController.text,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _emailController.text,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Profile form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: (val) => val == null || val.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email cannot be empty';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) return 'Invalid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Save Changes',
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Preferences',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Notification Toggle
            SwitchListTile(
              title: const Text('Daily Learning Reminders'),
              subtitle: Text('Receive daily notifications to continue studying'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            // Time Picker list item
            if (_notificationsEnabled) ...[
              ListTile(
                title: const Text('Reminder Time'),
                trailing: Text(
                  _reminderTime,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _selectTime,
              ),
              ListTile(
                title: const Text('Test Daily Notification'),
                subtitle: const Text('Trigger a test notification instantly'),
                trailing: Icon(Icons.notifications_active, color: theme.colorScheme.primary),
                onTap: () async {
                  await NotificationService.showInstantNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Instant test notification triggered!')),
                    );
                  }
                },
              ),
            ],
            // Theme Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark UI themes'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
            const SizedBox(height: 40),
            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: _logout,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
