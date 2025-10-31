import 'package:flutter/material.dart';
import 'package:winter_arc/services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _notificationService = NotificationService();
  
  bool _notificationsEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getReminderSettings();
    setState(() {
      _notificationsEnabled = settings['enabled'] as bool;
      _reminderTime = TimeOfDay(
        hour: settings['hour'] as int,
        minute: settings['minute'] as int,
      );
      _loading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Request permission first
      final granted = await _notificationService.requestPermissions();
      
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notification permission denied'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Schedule notification
      await _notificationService.scheduleDailyReminder(
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
        title: '💪 Winter Arc Reminder',
        body: NotificationService.getMotivationalMessage(),
      );

      setState(() => _notificationsEnabled = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Daily reminder set for ${_reminderTime.format(context)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Cancel notifications
      await _notificationService.cancelAllNotifications();
      setState(() => _notificationsEnabled = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminders disabled'),
          ),
        );
      }
    }
  }

  Future<void> _changeReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _reminderTime = picked);

      // Update the scheduled notification if enabled
      if (_notificationsEnabled) {
        await _notificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
          title: '💪 Winter Arc Reminder',
          body: NotificationService.getMotivationalMessage(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reminder time updated to ${picked.format(context)}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _testNotification() async {
    await _notificationService.showImmediateNotification(
      title: '💪 Winter Arc Test',
      body: 'If you see this, notifications are working!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
        ),
      );
    }
  }

  Future<void> _testScheduledNotification() async {
    await _notificationService.scheduleTestNotification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scheduled test in 1 minute! Keep the app open or in background.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Icon(
            Icons.notifications_active,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Daily Reminders',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Stay consistent with daily workout reminders',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Enable/Disable Toggle
          Card(
            child: SwitchListTile(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              title: const Text('Daily Reminders'),
              subtitle: Text(
                _notificationsEnabled
                    ? 'Reminders are enabled'
                    : 'Tap to enable daily reminders',
              ),
              secondary: Icon(
                _notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _notificationsEnabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reminder Time
          Card(
            child: ListTile(
              leading: Icon(
                Icons.access_time,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.edit),
              onTap: _changeReminderTime,
              enabled: _notificationsEnabled,
            ),
          ),
          const SizedBox(height: 16),

          // Test Notification Buttons
          OutlinedButton.icon(
            onPressed: _testNotification,
            icon: const Icon(Icons.send),
            label: const Text('Send Instant Test'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _testScheduledNotification,
            icon: const Icon(Icons.schedule),
            label: const Text('Test Scheduled (1 min)'),
          ),
          const SizedBox(height: 32),

          // Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tip',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Daily reminders help you stay consistent throughout the 90-day Winter Arc challenge. Choose a time that works best for your schedule!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Motivational Messages Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Example Messages',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...NotificationService.motivationalMessages.take(3).map(
                      (message) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                Text(
                  '...and ${NotificationService.motivationalMessages.length - 3} more!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
