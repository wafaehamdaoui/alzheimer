class Person {
  final String name;
  final String relation;
  final String imagePath;

  Person({
    required this.name,
    required this.relation,
    required this.imagePath,
  });

  // Factory constructor to create a Person object from a JSON response
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'] as String,
      relation: json['relation'] as String,
      imagePath: json['imagePath'] as String,
    );
  }

  // Method to convert a Person object to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'imagePath': imagePath,
    };
  }
}
