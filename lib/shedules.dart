import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:voice_based_notification/variables.dart';

class SchedulesPage extends StatefulWidget {
  const SchedulesPage({super.key});

  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic>? schedules;
  late Future<void> _loadSchedulesFuture;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadSchedulesFuture = _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      String? studentInfoJson = await storage.read(key: 'student_information');
      if (studentInfoJson != null) {
        Map<String, dynamic> studentInfo = json.decode(studentInfoJson);
        String department = studentInfo['department']?.toString() ?? '';
        String year = studentInfo['year']?.toString() ?? '';
        String semester = studentInfo['semester']?.toString() ?? '';

        if (department.isEmpty || year.isEmpty) {
          throw Exception('Invalid student information');
        }

        final fetchedSchedules =
            await apiService.fetchSchedules(department, year, semester);

        setState(() {
          schedules = fetchedSchedules;
          _events = _getEventsMap(fetchedSchedules);
        });
      } else {
        throw Exception('No student information found');
      }
    } catch (e) {
      print('Error loading schedules: $e');
      throw e;
    }
  }

  Map<DateTime, List<dynamic>> _getEventsMap(List<dynamic> schedules) {
    Map<DateTime, List<dynamic>> eventsMap = {};
    for (var schedule in schedules) {
      // Parse the date and normalize it to midnight local time
      DateTime fullDate = DateTime.parse(schedule['date']).toLocal();
      DateTime dateOnly = DateTime(fullDate.year, fullDate.month, fullDate.day);

      print("Original date: ${schedule['date']}");
      print("Normalized date: $dateOnly");

      if (eventsMap[dateOnly] == null) eventsMap[dateOnly] = [];
      eventsMap[dateOnly]!.add(schedule);
    }
    return eventsMap;
  }

// Update the event loader to also normalize the input date
  List<dynamic> _getEventsForDay(DateTime day) {
    // Normalize the input day to midnight
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadSchedulesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  decoration: BoxDecoration(
                    color: primaryColor,
                  ),
                  titleTextStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: _buildEventList(),
              ),
            ],
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildEventList() {
    if (_selectedDay == null) return Container();

    List<dynamic> events = _getEventsForDay(_selectedDay!);
    return ListView.builder(
      itemCount: events.length,
      padding: EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Optional: Add onTap functionality
                },
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type and Time Row
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              event['type'] ?? 'Event',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            '${event['startTime']} - ${event['endTime']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0),

                      // Details Grid
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 12.0,
                        children: [
                          if (event['instructor'] != null)
                            _buildDetailItem(
                                Icons.person, 'Lecturer', event['instructor']),
                          if (event['room'] != null)
                            _buildDetailItem(
                                Icons.room, 'Venue', event['room']),
                        ],
                      ),
                      SizedBox(height: 16.0),

                      // Days
                      if (event['days'] != null &&
                          (event['days'] as List).isNotEmpty) ...[
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Icon(Icons.event_repeat,
                                size: 20.0, color: Colors.grey[700]),
                            SizedBox(width: 8.0),
                            Text(
                              'Days: ${(event['days'] as List).join(", ")}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Date Added
                      if (event['dateAdded'] != null) ...[
                        SizedBox(height: 16.0),
                        Text(
                          'Added on: ${_formatDate(event['dateAdded'])}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.0, color: Colors.grey[700]),
          SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12.0,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
