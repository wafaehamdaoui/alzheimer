class Location {
  final int? id;
  final String title;
  final String coordinates;
  final String imagePath;

  Location({required this.id, required this.title, required this.coordinates, required this.imagePath});

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coordinates': coordinates,
      'imagePath': imagePath,
    };
  }

  // fromJson method
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      title: json['title'],
      coordinates: json['coordinates'],
      imagePath: json['imagePath'],
    );
  }
}
