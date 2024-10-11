import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api/api_services.dart';

Color primaryColor = Color(0xFFFFC42E);

FlutterSecureStorage storage = FlutterSecureStorage();

final ApiService apiService = ApiService();

bool isDarkMode = false;
