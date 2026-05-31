import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
String baseUrl = "https://taqwatrack.my.id/api";

  String? token;
  String? userName;
  String? userEmail;

  bool isLoading = false;

  bool get isLogin => token != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    userName = prefs.getString("user_name");
    userEmail = prefs.getString("user_email");

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "email": email.trim(),
          "password": password.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        token = data["token"];
        userName = data["user"]["name"];
        userEmail = data["user"]["email"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token!);
        await prefs.setString("user_name", userName ?? "");
        await prefs.setString("user_email", userEmail ?? "");

        isLoading = false;
        notifyListeners();

        return true;
      }

      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();

      print("Login error: $e");
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "name": name.trim(),
          "email": email.trim(),
          "password": password.trim(),
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        token = data["token"];
        userName = data["user"]["name"];
        userEmail = data["user"]["email"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token!);
        await prefs.setString("user_name", userName ?? "");
        await prefs.setString("user_email", userEmail ?? "");

        isLoading = false;
        notifyListeners();

        return true;
      }

      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      notifyListeners();

      print("Register error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    if (token != null) {
      try {
        await http.post(
          Uri.parse("$baseUrl/logout"),
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        );
      } catch (e) {
        print("Logout API error: $e");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("user_name");
    await prefs.remove("user_email");

    token = null;
    userName = null;
    userEmail = null;

    notifyListeners();
  }
}