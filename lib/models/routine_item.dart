import 'package:flutter/material.dart';

class RoutineItem {
  final int? id;
  final String title;    // The title of the routine item
  final String category; // The category (e.g., 'medicine', 'exercise', 'task')
  final TimeOfDay time;  // The time for the routine item
  bool isDone;
  final int userId;

  RoutineItem({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.isDone,
    required this.userId,
  });

  // Convert a RoutineItem object into a Map (toJson)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'time': [time.hour, time.minute],
      'isDone': isDone,
      'userId': userId,
    };
  }

  // Create a RoutineItem object from a Map (fromJson)
  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      time:  TimeOfDay(
        hour:json['time'][0], 
        minute:json['time'][1], 
      ),
      isDone: json['done'] ,
      userId: json['userId'] as int,
    );
  }
}
