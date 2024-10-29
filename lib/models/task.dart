class Task {
  final int? id; 
  final String title;
  final String description;
  final bool isDone;
  final DateTime date;
  final int userId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.date,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      isDone: json['done'] as bool, 
      date: DateTime(
        json['date'][0], // Year
        json['date'][1], // Month
        json['date'][2], // Day
      ),
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'date': date.toIso8601String(), 
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'TaskResponse{id: $id, title: $title, isDone: $isDone, date: $date}';
  }
}
