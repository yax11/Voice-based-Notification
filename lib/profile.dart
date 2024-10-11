import 'dart:convert';
import 'package:flutter/material.dart';
import 'variables.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _name = '';
  String _faculty = '';
  String _department = '';
  String _year = '';
  String _fcmToken = '';
  String _appId = '';
  String _appInstallationId = '';
  String _userUniqueId = '';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final studentDataJson = await storage.read(key: 'student_information');
    if (studentDataJson != null) {
      final studentData = jsonDecode(studentDataJson);
      setState(() {
        _name = studentData['name'] ?? '';
        _faculty = studentData['faculty'] ?? '';
        _department = studentData['department'] ?? '';
        _year = studentData['year'] ?? '';
        _fcmToken = studentData['fcmToken'] ?? '';
        _appId = studentData['appId'] ?? '';
        _appInstallationId = studentData['appInstallationId'] ?? '';
        _userUniqueId = studentData['userUniqueId'] ?? '';
      });
    }
  }

  Future<void> _signOut() async {
    await storage.delete(key: 'student_information');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle
              ),
              child: Icon(Icons.person, size: 100,),
            ),
            SizedBox(height: 20),

            // User Information
            _buildInfoField('Name', _name),
            _buildInfoField('Faculty', _faculty),
            _buildInfoField('Department', _department),
            _buildInfoField('Year', _year),
            SizedBox(height: 20),

            // Sign Out Button
            ElevatedButton(
              // onPressed: _signOut,
              onPressed: () async {
                await storage.deleteAll();
                Navigator.pushNamedAndRemoveUntil(context, "/setup", (Route<dynamic> route) => false );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Sign Out', style: TextStyle(
                  fontSize: 18,
                  color: Colors.black
              )),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create information fields
  Widget _buildInfoField(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Color(0xFF2F2F2F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(width: 10),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }
}

