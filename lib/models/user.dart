
class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String profilePhotoUrl;
  final int age;
  final String profession;
  final String likes;
  final String dislikes;
  final String allergies;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.profilePhotoUrl,
    required this.age,
    required this.profession,
    required this.likes,
    required this.dislikes,
    required this.allergies,
  });

  // Factory method to create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String,
      age: json['age'] as int,
      profession: json['profession'] as String,
      likes: json['likes'] as String,
      dislikes: json['dislikes'] as String,
      allergies: json['allergies'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'profilePhotoUrl': profilePhotoUrl,
      'age': age,
      'profession': profession,
      'likes': likes,
      'dislikes': dislikes,
      'allergies': allergies,
    };
  }
}
