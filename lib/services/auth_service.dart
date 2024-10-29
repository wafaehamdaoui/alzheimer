import 'package:logger/logger.dart';
import 'package:myproject/models/authentication_response.dart';
import 'package:myproject/models/register_request.dart';
import 'package:myproject/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final Logger _logger = Logger();

  // Method for user login
  Future<AuthenticationResponse?> login(String username, String password) async {
    final url = Uri.parse('https://alzheimerbackend.onrender.com/api/users/auth/login');

    final response = await http.post(
      url,
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      AuthenticationResponse authResponse = AuthenticationResponse.fromJson(jsonResponse);

      // Save the token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authResponse.token);
      await prefs.setString('user_info', jsonEncode(authResponse.user.toJson()));
      await prefs.setInt('user_id', authResponse.user.id??0);
  
      return authResponse;
    } else {
      _logger.e('Login failed: ${response.body}');
      return null;
    }
  
  }

  // Method for user logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Remove the token on logout
  }

  // Retrieve the token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Retrieve the token
  }
  
  // Method to get the user info from SharedPreferences
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userInfo = prefs.getString('user_info');

    if (userInfo != null) {
      return User.fromJson(jsonDecode(userInfo));
    }
    return null; 
  }

  // Check if the user is logged in (i.e., token exists)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null; // User is logged in if token exists
  }

  Future<User?> updateUserProfile(User updatedUser) async{
    final token = await getToken();
    final url = Uri.parse('https://alzheimerbackend.onrender.com/api/users/${updatedUser.id}');

    try {
      final response = await http.post(
      url,
      body: jsonEncode(updatedUser),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        User userRespone = User.fromJson(jsonResponse);

        // Save the token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', jsonEncode(userRespone.toJson()));

        return userRespone;
      } else {
        _logger.e('Edit failed: ${response.body}');
        return null;
      }
    } catch (e) {
       _logger.e('Edit failed: $e');
       rethrow;
    }
  }
  Future<User?> resetPassword(String newPassword) async{
    final token = await getToken();
    final user = await getUser();
    final url = Uri.parse('https://alzheimerbackend.onrender.com/api/users/reset/${user!.id}');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(newPassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        User userRespone = User.fromJson(jsonResponse);

        // Save the token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_info', jsonEncode(userRespone.toJson()));

        return userRespone;
      } else {
        _logger.e('Password Reset failed: ${response.body}');
        return null;
      }
    } catch (e) {
       _logger.e('Password Reset failed: $e');
       rethrow;
    }
  }

  Future<List<User>> getAllUser() async{
    final token = await getToken();
    final url = Uri.parse('https://alzheimerbackend.onrender.com/api/users');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as List;
      
      // Convert the JSON list to a list of User objects
      return jsonResponse.map((user) => User.fromJson(user)).toList();
      } else {
        _logger.e('Password Reset failed: ${response.body}');
        return [];
      }
    } catch (e) {
       _logger.e('Password Reset failed: $e');
       rethrow;
    }
  }

  inviteMember(String email) async {
    final token = await getToken();
    final url = Uri.parse('https://alzheimerbackend.onrender.com/api/users/invite/$email');
    try {
      final response = await http.post(
        url,
        // body: jsonEncode(email),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return true  ;    
      } else {
        _logger.e('Invitation failed: ${response.body}');
        return false;
      }
    } catch (e) {
       _logger.e('Invitation failed: $e');
       rethrow;
    }
  }

  toggleUserStatus(int id, bool isActivating) async{
    final token = await getToken();
    final url = Uri.parse('https://alzheimerbackend.onrender.com/api/users/change-status/$id');
    try {
      final response = await http.patch(
        url,
         //body: jsonEncode(i),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return true  ;    
      } else {
        _logger.e('Activation failed: ${response.body}');
        return false;
      }
    } catch (e) {
       _logger.e('Deactivation failed: $e');
       rethrow;
    }
  }

  signUp(RegisterRequest request) async{
    final url = Uri.parse('https://alzheimerbackend.onrender.com/api/users/auth/signup');

    try {
      final response = await http.post(
      url,
      body: jsonEncode(request),
      headers: {
        'Content-Type': 'application/json',
      },
    );
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        User userRespone = User.fromJson(jsonResponse);
        _logger.i('added user: ${response.body}');
        return userRespone;
      } else {
        _logger.e('Add failed: ${response.body}');
        return null;
      }
    } catch (e) {
       _logger.e('Add failed: $e');
    }
  }
}
