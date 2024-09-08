import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'variables.dart'; // Assuming you have primaryColor in variables.dart
import '/api/api_services.dart'; // Import the ApiService
import 'package:device_info_plus/device_info_plus.dart'; // Add this import

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  // Dropdown values
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedYear;

  // FCM token and app ID
  String? _fcmToken;
  String? _appId;

  // Secure storage for saving information
  final storage = const FlutterSecureStorage();

  // Faculty and departments data
  final Map<String, List<String>> _facultiesAndDepartments = {
    'Natural and Applied Sciences': [
      'Computer Science',
      'Physics',
      'Mathematics',
      'Biology',
      'Chemistry'
    ],
    'Public Administration': [
      'Public Management',
      'Policy Analysis',
      'Urban Planning',
      'Governance',
      'Human Resource Management'
    ],
    'Law': [
      'Civil Law',
      'Criminal Law',
      'Corporate Law',
      'International Law',
      'Constitutional Law'
    ],
    'Arts': [
      'Literature',
      'History',
      'Philosophy',
      'Linguistics',
      'Fine Arts'
    ],
  };

  // List of available years/levels
  final List<String> _years = [
    'Year 1',
    'Year 2',
    'Year 3',
    'Year 4',
  ];

  // Instance of the ApiService
  final ApiService apiService = ApiService();

  // State variables for loading and button disabling
  bool _isLoading = false;

  String? _deviceId; // Add this line

  @override
  void initState() {
    super.initState();
    _initializeFCM();
    _checkStudentInformation();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor;
    }
  }

  // Initialize FCM and get token and app ID
  Future<void> _initializeFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    _fcmToken = await messaging.getToken();
    _appId = await messaging.getAPNSToken(); // Optionally use this as an app ID

    print("FCM Token: $_fcmToken");
    print("App ID: $_appId");
  }

  // Check if student information is already stored
  Future<void> _checkStudentInformation() async {
    String? studentInfo = await storage.read(key: 'student_information');
    if (studentInfo != null) {
      // Navigate to dashboard if information is already stored
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  // Save student information to secure storage and send to the server
  Future<void> _saveStudentInformation() async {
    if (_selectedFaculty != null && _selectedDepartment != null && _selectedYear != null) {
      // Prepare the data to send
      Map<String, String> studentData = {
        'name': 'Student Name', // Ensure this is provided
        'faculty': _selectedFaculty!,
        'department': _selectedDepartment!,
        'year': _selectedYear!,
        'fcmToken': _fcmToken ?? '',
        'appId': _appId ?? '',
        // 'appInstallationId': _appId ?? '' // Ensure this is provided
      'appInstallationId': _deviceId ?? _fcmToken ?? '' // Use device ID or FCM token as fallback
      };

      studentData.forEach((item, index){
        print(item);
      });

      setState(() {
        _isLoading = true; // Show loading and disable the button
      });

      try {
        // Make the request and ensure it doesn't exceed 20 seconds
        var response = await apiService
            .registerUser(studentData)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 201) {
          // Save data in secure storage
          await storage.write(key: 'student_information', value: jsonEncode(studentData));

          // Navigate to the dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register: ${response.body}')),
          );
        }
      } on TimeoutException catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request timed out, please try again')),
        );
      } catch (e) {
        print("Error details: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading and enable the button
        });
      }
    } else {
      // Show a warning message if any field is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setup Your Profile',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false, // Remove back button
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: Colors.grey, // Bottom border color
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.1,
                vertical: constraints.maxHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Faculty Dropdown
                  const Text(
                    'Select Faculty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Less bold
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing between text and dropdown
                  DropdownButton<String>(
                    value: _selectedFaculty,
                    isExpanded: true,
                    hint: const Text('Choose Faculty'),
                    items: _facultiesAndDepartments.keys.map((String faculty) {
                      return DropdownMenuItem<String>(
                        value: faculty,
                        child: Text(faculty),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFaculty = newValue;
                        _selectedDepartment = null; // Reset department selection
                      });
                    },
                  ),
                  const SizedBox(height: 30), // Increased space between sections

                  // Department Dropdown
                  const Text(
                    'Select Department',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Less bold
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing between text and dropdown
                  DropdownButton<String>(
                    value: _selectedDepartment,
                    isExpanded: true,
                    hint: const Text('Choose Department'),
                    items: _selectedFaculty == null
                        ? []
                        : _facultiesAndDepartments[_selectedFaculty]!
                        .map((String department) {
                      return DropdownMenuItem<String>(
                        value: department,
                        child: Text(department),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30), // Increased space between sections

                  // Year/Level Dropdown
                  const Text(
                    'Select Year/Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Less bold
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing between text and dropdown
                  DropdownButton<String>(
                    value: _selectedYear,
                    isExpanded: true,
                    hint: const Text('Choose Year/Level'),
                    items: _years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 40), // Space before the button

                  // Submit Button with Loading Indicator
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator() // Show loading indicator if loading
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Button color
                        side: BorderSide(color: primaryColor), // Border color as primary color
                        textStyle: TextStyle(color: primaryColor), // Text color
                      ),
                      onPressed: _isLoading ? null : _saveStudentInformation, // Disable button while loading
                      child: const Text(
                        'Continue',
                        style: TextStyle(color: Colors.black), // Text color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
