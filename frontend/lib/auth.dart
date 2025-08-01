import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'redirects.dart';

class AuthService {
  static Future<bool> loginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    final url = Uri.parse(login);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      return true;
    } else {
      handleApiError(response, context);
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>?> whoami(
    BuildContext context, {
    bool silent = false,
  }) async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(Whoami),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (!silent) handleApiError(response, context);
    return null;
  }

  static Future<bool> sendOTP(String email, BuildContext context) async {
    final response = await http.post(
      Uri.parse(sendotp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim().toLowerCase()}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      handleApiError(response, context);
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendOTPWithResponse(String email) async {
    try {
      final response = await http.post(
        Uri.parse(sendotp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? data['detail'] ?? 'Unknown error',
          'code': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<bool> registerUser(
    String username,
    String fullname,
    String email,
    String password,
    BuildContext context,
  ) async {
    final response = await http.post(
      Uri.parse(register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'fullname': fullname.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      handleApiError(response, context);
      return false;
    }
  }

  static void handleApiError(http.Response response, BuildContext context) {
    try {
      final data = jsonDecode(response.body);
      final detail = (data['detail'] ?? 'unknown_error')
          .toString()
          .toLowerCase();

      final messages = {
        'email_not_found': 'No account found with that email.',
        'incorrect_password': 'Incorrect password.',
        'email_already_verified_or_registered':
            'This email is already registered or verified.',
        'email_required': 'Email is required.',
        'email_not_verified': 'Email is not verified. Check your inbox.',
        'email_already_registered': 'This email is already registered.',
        'verification_already_sent':
            'A verification link has already been sent.',
        'email_send_failed':
            'Failed to send verification email. Try again later.',
        'invalid or expired verification link':
            'This link is invalid or has expired.',
        'email is already verified': 'This email is already verified.',
        'unknown_error': 'An unknown error occurred.',
      };

      showError(messages[detail] ?? 'Something went wrong: $detail', context);
    } catch (e) {
      showError("Unexpected error: ${e.toString()}", context);
    }
  }

  static void showError(String message, BuildContext context) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
