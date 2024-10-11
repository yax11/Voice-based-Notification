import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Define the base URI for the API
  // final String baseUri = "http://192.168.43.38:3000";
  final String baseUri = "http://192.168.0.145:3000";

  // Method to perform a GET request
  Future<http.Response> getRequest(String endpoint) async {
    final String url = '$baseUri$endpoint';

    try {
      final response = await http.get(Uri.parse(url));
      _handleResponse(response);
      return response;
    } catch (e) {
      print("Error during GET request: $e");
      throw Exception("Failed to perform GET request");
    }
  }

  // Method to perform a POST request
  Future<http.Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    final String url = '$baseUri$endpoint';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      print("Error during POST request: $e");
      throw Exception("Failed to perform POST request");
    }
  }

  // Method to perform a PUT request
  Future<http.Response> putRequest(
      String endpoint, Map<String, dynamic> body) async {
    final String url = '$baseUri$endpoint';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      print("Error during PUT request: $e");
      throw Exception("Failed to perform PUT request");
    }
  }

  // Method to perform a DELETE request
  Future<http.Response> deleteRequest(String endpoint) async {
    final String url = '$baseUri$endpoint';
    try {
      final response = await http.delete(Uri.parse(url));
      _handleResponse(response);
      return response;
    } catch (e) {
      print("Error during DELETE request: $e");
      throw Exception("Failed to perform DELETE request");
    }
  }

  // Private method to handle responses
  void _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Request was successful
      print("Request successful with status: ${response.statusCode}");
    } else {
      // Request failed
      print("Request failed with status: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception("Request failed with status: ${response.statusCode}");
    }
  }

  // Method to register a user (specific POST request for registration)
  Future<http.Response> registerUser(Map<String, dynamic> body) async {
    final String endpoint = '/register'; // Your register endpoint
    return await postRequest(endpoint, body);
  }

  // Method to send audio along with department, year, title, and message
  Future<void> sendAudio(File audioFile, String department, String year,
      String title, String message) async {
    final String url = '$baseUri/upload/audio';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFile.path));

      // Add department, year, title, and message as fields in the multipart request
      request.fields['department'] = department;
      request.fields['year'] = year;
      request.fields['title'] = title;
      request.fields['message'] = message;

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Audio uploaded successfully');
      } else {
        throw Exception('Failed to upload audio');
      }
    } catch (e) {
      print('Error during audio upload: $e');
      throw Exception('Audio upload failed');
    }
  }

  Future<List<dynamic>> fetchNotifications(
      String department, String year) async {
    if (department.isEmpty || year.isEmpty) {
      throw Exception('Department and year are required');
    }

    final String endpoint = '/notifications?department=$department&year=$year';

    print('Fetching notifications for department: $department, year: $year');

    try {
      final response = await getRequest(endpoint);
      print('API Response status code: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> notifications = json.decode(response.body);
        print('Number of notifications fetched: ${notifications.length}');

        // Download audio files if needed
        for (var notification in notifications) {
          if (notification.containsKey('filename')) {
            print(
                'Downloading audio for notification: ${notification['filename']}');
            await _downloadAndSaveAudio(notification['filename']);
          }
        }

        return notifications;
      } else if (response.statusCode == 400) {
        throw Exception('Department and year are required');
      } else {
        print('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw e;
    }
  }

  // Download audio file if it doesn't already exist locally
  Future<void> _downloadAndSaveAudio(String filename) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$filename';
    final File file = File(filePath);
    if (!file.existsSync()) {
      final String url = '$baseUri/audio/$filename';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('Audio file saved: $filePath');
      } else {
        throw Exception('Failed to download audio file');
      }
    } else {
      print('Audio file already exists locally: $filePath');
    }
  }

  Future<List<dynamic>> fetchSchedules(
      String department, String year, String semester) async {
    if (department.isEmpty || year.isEmpty) {
      throw Exception('Department and year are required');
    }

    String endpoint = '/schedules?department=$department&year=$year';
    if (semester.isNotEmpty) {
      endpoint += '&semester=$semester';
    }

    print(
        'Fetching schedules for department: $department, year: $year, semester: $semester');

    try {
      final response = await getRequest(endpoint);
      print('API Response status code: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> schedules = json.decode(response.body);
        print('Number of schedules fetched: ${schedules.length}');

        return schedules;
      } else if (response.statusCode == 400) {
        throw Exception('Department and year are required');
      } else if (response.statusCode == 500) {
        throw Exception('Error fetching schedules');
      } else {
        print('API request failed with status code: ${response.statusCode}');
        throw Exception('Failed to fetch schedules');
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      throw e;
    }
  }

  Future<void> sendSchedule({
    required String type,
    required String title,
    required String faculty,
    required String department,
    required String year,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String venue,
    required String instructor,
  }) async {
    final String url = '$baseUri/schedules';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          // 'type': type,
          'type': "Lecture",
          'title': title,
          'faculty': faculty,
          'department': department,
          'year': year,
          'date': date.toIso8601String(),
          'startTime': startTime,
          'endTime': endTime,
          'venue': venue,
          'instructor': instructor,
        }),
      );
      if (response.statusCode == 201) {
        print('Schedule saved successfully');
      } else {
        throw Exception(
            'Failed to save schedule. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during schedule save: $e');
      throw Exception('Schedule save failed');
    }
  }
}
