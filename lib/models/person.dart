class Person {
  final String name;
  final String relation;
  final String phone;
  final String imagePath;
  final int userId;

  Person({
    required this.name,
    required this.relation,
    required this.phone,
    required this.imagePath,
    required this.userId,
  });

  // Factory constructor to create a Person object from a JSON response
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'] as String,
      relation: json['relation'] as String,
      phone: json['phone'] as String,
      imagePath: json['imagePath'] as String,
      userId: json['userId'] as int,
    );
  }

  // Method to convert a Person object to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'phone': phone,
      'imagePath': imagePath,
      'userId': userId,
    };
  }
}
