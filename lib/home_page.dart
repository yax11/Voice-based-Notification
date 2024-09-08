import 'package:flutter/material.dart';
import 'package:voice_based_notification/variables.dart';
import 'package:table_calendar/table_calendar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages for bottom navigation
  final List<Widget> _pages = [
    const HomeContent(),
    SchedulesPage(),
    SettingsPage(),
  ];

  // Function to handle bottom navigation item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white, // Use primary color for AppBar
          title: Row(
            children: [
              Container(
                width: 40,
                height:40,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async{
                    // void studentInfo = await storage.deleteAll();
                    await storage.deleteAll();
                    Navigator.pushReplacementNamed(context, "/setup",);
                    // print("EXIT ATTEMPTED ");
                    // Navigator.pop(context); // Action for the button
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black, // Icon color
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("Home"),
              ),
              Expanded(child: Container(),

              ),
              Align(
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20)
                  ),
                  onPressed: () {
                    print("COURSE REP");
                    // Navigator.pop(context); // Action for the button
                  },
                  icon: Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.black,
                          ),
                        ),
                        Text("Admin",style: TextStyle(fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        elevation: 0,
        bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          color: primaryColor, // Transparent background
          child: Container(
            height: 1.0, // Thickness of the bottom border
            color: Colors.transparent, // Color of the bottom border
          ),
        ),
      ),
        ),
        body: _pages[_selectedIndex], // Display the current page
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Schedules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex, // Set the current index
          selectedItemColor: primaryColor, // Use primary color for selected item
          onTap: _onItemTapped, // Handle tap on items
        ),
      ),
    );
  }
}

// Define a custom list item widget
class CustomListItem extends StatelessWidget {
  final String time;
  final String title;
  final VoidCallback onPlay;

  const CustomListItem({
    Key? key,
    required this.time,
    required this.title,
    required this.onPlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0), // Space between items
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1), // Faded primary color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor.withOpacity(0.7), // Slightly faded primary color
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.play_circle_fill, color: primaryColor),
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}

// Define the content of the Home tab with custom list items
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CustomListItem(
            time: "10:00 AM",
            title: "Morning Briefing",
            onPlay: () {
              print("Playing Morning Briefing");
              // Implement your action here
            },
          ),
          CustomListItem(
            time: "12:30 PM",
            title: "Lunch Meeting",
            onPlay: () {
              print("Playing Lunch Meeting");
              // Implement your action here
            },
          ),
          CustomListItem(
            time: "03:00 PM",
            title: "Afternoon Report",
            onPlay: () {
              print("Playing Afternoon Report");
              // Implement your action here
            },
          ),
          CustomListItem(
            time: "05:15 PM",
            title: "Daily Wrap-Up",
            onPlay: () {
              print("Playing Daily Wrap-Up");
              // Implement your action here
            },
          ),
          CustomListItem(
            time: "08:00 PM",
            title: "Evening Summary",
            onPlay: () {
              print("Playing Evening Summary");
              // Implement your action here
            },
          ),
        ],
      ),
    );
  }
}


// Placeholder for Schedules page
class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month; // To control the format of the calendar
  DateTime _focusedDay = DateTime.now(); // Initial focused day
  DateTime? _selectedDay; // Selected day

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1), // Earliest date
            lastDay: DateTime.utc(2030, 12, 31), // Latest date
            focusedDay: _focusedDay, // Currently focused day
            calendarFormat: _calendarFormat, // Current calendar format
            selectedDayPredicate: (day) {
              // Check if a day is selected
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              // Update the selected day and the focused day
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              // Update the calendar format
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // Update the focused day
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: primaryColor, // Use primary color for selected day
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: primaryColor.withOpacity(0.6), // Different color for today
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: Colors.black),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // Hide the format button
              titleCentered: true, // Center the title
              decoration: BoxDecoration(
                color: primaryColor, // Use primary color for header
              ),
              titleTextStyle: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
// Placeholder for Settings page
//import 'package:flutter/material.dart';
//import 'package:voice_based_notification/variables.dart'; // Import your variables file for primaryColor

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedNotification = 'Daily'; // Default selection for notifications
  String _selectedCalendarView = 'Month'; // Default selection for calendar view
  String _selectedReminderTime = '30 minutes before'; // Default selection for reminder time
  String _selectedTheme = 'Light'; // Default selection for theme

  // Switch states for additional settings
  bool _isSoundEnabled = true;
  bool _isCalendarSyncEnabled = true;
  bool _is24HourFormat = false;
  bool _isAutoBackupEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: Colors.grey, // Bottom border color
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notification Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile(
                    title: const Text('Daily'),
                    value: 'Daily',
                    groupValue: _selectedNotification,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedNotification = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Weekly'),
                    value: 'Weekly',
                    groupValue: _selectedNotification,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedNotification = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Calendar View',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile(
                    title: const Text('Month'),
                    value: 'Month',
                    groupValue: _selectedCalendarView,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedCalendarView = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Week'),
                    value: 'Week',
                    groupValue: _selectedCalendarView,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedCalendarView = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Default Reminder Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile(
                    title: const Text('10 minutes before'),
                    value: '10 minutes before',
                    groupValue: _selectedReminderTime,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedReminderTime = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('30 minutes before'),
                    value: '30 minutes before',
                    groupValue: _selectedReminderTime,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedReminderTime = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('1 hour before'),
                    value: '1 hour before',
                    groupValue: _selectedReminderTime,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedReminderTime = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Theme Mode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Column(
                children: [
                  RadioListTile(
                    title: const Text('Light'),
                    value: 'Light',
                    groupValue: _selectedTheme,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Dark'),
                    value: 'Dark',
                    groupValue: _selectedTheme,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _selectedTheme = value.toString();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(), // Divider to separate sections
              const SizedBox(height: 10),
              // Toggle switches for additional settings
              SwitchListTile(
                title: const Text('Enable Sound Notifications'),
                value: _isSoundEnabled,
                activeColor: primaryColor,
                onChanged: (bool value) {
                  setState(() {
                    _isSoundEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Allow Calendar Sync'),
                value: _isCalendarSyncEnabled,
                activeColor: primaryColor,
                onChanged: (bool value) {
                  setState(() {
                    _isCalendarSyncEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Use 24-Hour Format'),
                value: _is24HourFormat,
                activeColor: primaryColor,
                onChanged: (bool value) {
                  setState(() {
                    _is24HourFormat = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Enable Auto-Backup'),
                value: _isAutoBackupEnabled,
                activeColor: primaryColor,
                onChanged: (bool value) {
                  setState(() {
                    _isAutoBackupEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
