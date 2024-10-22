import 'package:myproject/models/user.dart';

class AuthenticationResponse {
  final String token;
  final User user;

  AuthenticationResponse({required this.token, required this.user});

  // Factory method to create an AuthenticationResponse from a JSON map
  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      token: json['token'] as String,    // Convert 'token' to String
      user: User.fromJson(json['user']), // Parse the nested 'user' JSON into a User object
    );
  }
}