import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class UserService {
  String authEndpoint = "http://10.0.2.2:8888";

  Future<bool> loginUser(
      {required String username,
      required String password,
      required String selectedRole}) async {
    try {
      final response = await http.post(
        Uri.parse("$authEndpoint/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];

        // ✅ Decode JWT
        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

        final userId = data['user_id'].toString(); // Also present in response
        final email = decodedToken['email'];
        final username = decodedToken['preferred_username'];

        // ✅ Store in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', accessToken);
        await prefs.setString('userId', userId);
        await prefs.setString('email', email);
        await prefs.setString('username', username);
        await prefs.setString('role', selectedRole);

        print("Login Successfully");

        return true;
      } else {
        print('Login failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> registerUser({
    required String firstname,
    required String lastname,
    required String email,
    required String username,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$authEndpoint/auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstname,
          'lastName': lastname,
          'email': email,
          'username': username,
          'phoneNumber': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Registration failed: ${response.statusCode}');
        print('Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('No token found');
        return null;
      }

      final response = await http.get(
        Uri.parse("$authEndpoint/api/user/$userId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromMap(data);
      } else {
        print('Failed to fetch user: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<bool> updateUserById({
    required String userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$authEndpoint/api/user/profile/basic?userId=$userId"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "phoneNumber": phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ User updated successfully");
        return true;
      } else {
        print("❌ Failed to update user: ${response.statusCode}");
        print("Body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updating user: $e");
      return false;
    }
  }

  saveToken() {}

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('username');
    print("User logged out successfully.");
  }

  Future<String?> getUsernameById(String userId) async {
    final user = await getUserById(userId);
    return user?.username;
  }
}
