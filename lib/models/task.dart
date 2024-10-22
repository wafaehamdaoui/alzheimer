import 'dart:convert';

class Task {
  final int? id; 
  final String title;
  final bool isDone;
  final DateTime date;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.date,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      title: json['title'] as String,
      isDone: json['done'] as bool, 
      date: DateTime(
        json['date'][0], // Year
        json['date'][1], // Month
        json['date'][2], // Day
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'date': date.toIso8601String(), 
    };
  }

  @override
  String toString() {
    return 'TaskResponse{id: $id, title: $title, isDone: $isDone, date: $date}';
  }
}
