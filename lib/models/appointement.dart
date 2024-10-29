import 'package:flutter/material.dart';

class Appointment {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time; 
  final int userId;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.userId,
  });

  // Factory method to create an AppointmentResponse object from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime(
        json['date'][0], // Year
        json['date'][1], // Month
        json['date'][2], // Day
      ),
      time:  TimeOfDay(
        hour:json['time'][0], 
        minute:json['time'][1], 
      ),
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(), 
      'time': [time.hour, time.minute],
      'userId': userId,
    };
  }
}
