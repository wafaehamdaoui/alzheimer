class Location {
  final int? id;
  final String title;
  final String coordinates;
  final String imagePath;
  final int userId;

  Location({
    required this.id, 
    required this.title, 
    required this.coordinates, 
    required this.imagePath,
    required this.userId,});

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coordinates': coordinates,
      'imagePath': imagePath,
      'userId': userId,
    };
  }

  // fromJson method
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      title: json['title'],
      coordinates: json['coordinates'],
      imagePath: json['imagePath'],
      userId: json['userId'] as int,
    );
  }
}
