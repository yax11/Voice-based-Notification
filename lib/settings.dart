import 'package:flutter/material.dart';
import 'package:voice_based_notification/variables.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedNotification = 'Daily';
  String _selectedCalendarView = 'Month';
  String _selectedReminderTime = '30 minutes before';
  String _selectedTheme = 'Light';
  bool _isSoundEnabled = true;
  bool _isCalendarSyncEnabled = true;
  bool _is24HourFormat = false;
  bool _isAutoBackupEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = await storage.read(key: 'app_settings');
      if (settingsJson != null) {
        final settings = json.decode(settingsJson);
        setState(() {
          _selectedNotification = settings['notification'] ?? 'Daily';
          _selectedCalendarView = settings['calendarView'] ?? 'Month';
          _selectedReminderTime = settings['reminderTime'] ?? '30 minutes before';
          _selectedTheme = settings['theme'] ?? 'Light';
          _isSoundEnabled = settings['soundEnabled'] ?? true;
          _isCalendarSyncEnabled = settings['calendarSync'] ?? true;
          _is24HourFormat = settings['24HourFormat'] ?? false;
          _isAutoBackupEnabled = settings['autoBackup'] ?? false;
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      // Optionally show an error message to the user
    }
  }

  Future<void> _saveSettings() async {
    final scaffold = ScaffoldMessenger.of(context);

    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Saving settings...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final settings = {
        'notification': _selectedNotification,
        'calendarView': _selectedCalendarView,
        'reminderTime': _selectedReminderTime,
        'theme': _selectedTheme,
        'soundEnabled': _isSoundEnabled,
        'calendarSync': _isCalendarSyncEnabled,
        '24HourFormat': _is24HourFormat,
        'autoBackup': _isAutoBackupEnabled,
      };

      await storage.write(
        key: 'app_settings',
        value: json.encode(settings),
      );

      scaffold.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Settings saved successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error saving settings: $e');
      scaffold.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Error saving settings'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRadioOption(String title, String value, String groupValue, Function(String?) onChanged) {
    return SizedBox(
      height: 40,
      child: RadioListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 14),
        ),
        value: value,
        groupValue: groupValue,
        activeColor: primaryColor,
        onChanged: onChanged,
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Notification Preferences'),
                  _buildRadioOption('Daily', 'Daily', _selectedNotification,
                          (value) => setState(() => _selectedNotification = value!)),
                  _buildRadioOption('Weekly', 'Weekly', _selectedNotification,
                          (value) => setState(() => _selectedNotification = value!)),

                  _buildSectionTitle('Calendar View'),
                  _buildRadioOption('Month', 'Month', _selectedCalendarView,
                          (value) => setState(() => _selectedCalendarView = value!)),
                  _buildRadioOption('Week', 'Week', _selectedCalendarView,
                          (value) => setState(() => _selectedCalendarView = value!)),

                  _buildSectionTitle('Default Reminder Time'),
                  _buildRadioOption('10 minutes before', '10 minutes before', _selectedReminderTime,
                          (value) => setState(() => _selectedReminderTime = value!)),
                  _buildRadioOption('30 minutes before', '30 minutes before', _selectedReminderTime,
                          (value) => setState(() => _selectedReminderTime = value!)),
                  _buildRadioOption('1 hour before', '1 hour before', _selectedReminderTime,
                          (value) => setState(() => _selectedReminderTime = value!)),

                  Divider(height: 32),

                  // Toggle switches
                  SwitchListTile(
                    title: Text('Enable Sound Notifications', style: TextStyle(fontSize: 14)),
                    value: _isSoundEnabled,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => _isSoundEnabled = value),
                    dense: true,
                  ),
                  SwitchListTile(
                    title: Text('Allow Calendar Sync', style: TextStyle(fontSize: 14)),
                    value: _isCalendarSyncEnabled,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => _isCalendarSyncEnabled = value),
                    dense: true,
                  ),
                  SwitchListTile(
                    title: Text('Use 24-Hour Format', style: TextStyle(fontSize: 14)),
                    value: _is24HourFormat,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => _is24HourFormat = value),
                    dense: true,
                  ),
                  SwitchListTile(
                    title: Text('Enable Auto-Backup', style: TextStyle(fontSize: 14)),
                    value: _isAutoBackupEnabled,
                    activeColor: primaryColor,
                    onChanged: (value) => setState(() => _isAutoBackupEnabled = value),
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: Offset(0, -4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}