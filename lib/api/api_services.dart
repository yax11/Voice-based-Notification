import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Define the base URI for the API
  final String baseUri = "http://192.168.43.38:3000";

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
  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
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

  // Method to register a user (specific POST request for registration)
  Future<http.Response> registerUser(Map<String, dynamic> body) async {
    final String endpoint = '/register'; // Your register endpoint
    return await postRequest(endpoint, body);
  }

  // Method to perform a PUT request
  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> body) async {
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
}
