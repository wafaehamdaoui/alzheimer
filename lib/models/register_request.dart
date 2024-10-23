class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String profilePhotoUrl;
  final int age;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.profilePhotoUrl,
    required this.age,
  });

  // Factory method to create a User object from a JSON map
  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String,
      age: json['age'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName,
      'profilePhotoUrl': profilePhotoUrl,
      'age': age,
    };
  }
}
