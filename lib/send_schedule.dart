import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voice_based_notification/variables.dart';

class SendSchedule extends StatefulWidget {
  @override
  _SendScheduleState createState() => _SendScheduleState();
}

class _SendScheduleState extends State<SendSchedule> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();

  // Date and time variables
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  void _saveForm() async {
    String? studentInfoJson = await storage.read(key: "student_information");

    if (studentInfoJson != null) {
      Map<String, dynamic> information = json.decode(studentInfoJson);
      String? faculty = information['faculty'];
      String? department = information['department'];
      String? year = information["year"];

      if (faculty == null || department == null || year == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Missing faculty, department, or year information.')),
        );
        return;
      }

      if (_formKey.currentState!.validate()) {
        // Process the form data
        String title = _titleController.text;
        String room = _roomController.text;
        String instructor = _instructorController.text;
        DateTime date = _selectedDate!.toUtc();  // Convert date to UTC
        String startTime = _startTime!.format(context);
        String endTime = _endTime!.format(context);

        try {
          await apiService.sendSchedule(
            type: 'lecture',
            title: title,
            faculty: faculty,
            department: department,
            year: year,
            date: date,
            startTime: startTime,
            endTime: endTime,
            venue: room,
            instructor: instructor,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lecture schedule saved successfully!')),
          );
          mounted ? Navigator.pop(context) : null;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save schedule: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student information not found.')),
      );
    }
  }


  // Pick date
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Pick start time
  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  // Pick end time
  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Send Schedules', style: TextStyle(fontSize: 16)),
            Expanded(child: Container()),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20)

            ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/courseRep");
              },
              icon: Text("Notifier", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title';
                  }
                  return null;
                },
              ),

              // Pick Date
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pick a date'
                    : DateFormat.yMd().format(_selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              // Pick Start Time
              ListTile(
                title: Text(_startTime == null
                    ? 'Pick a start time'
                    : _startTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: _pickStartTime,
              ),

              // Pick End Time
              ListTile(
                title: Text(_endTime == null
                    ? 'Pick an end time'
                    : _endTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: _pickEndTime,
              ),

              // Room Field
              TextFormField(
                controller: _roomController,
                decoration: InputDecoration(labelText: 'Venue'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the room';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30,),
              // Instructor Field
              TextFormField(
                controller: _instructorController,
                decoration: InputDecoration(labelText: 'Instructor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the instructor';
                  }
                  return null;
                },
              ),

              // Save Button
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor
                ),
                onPressed: _saveForm,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
