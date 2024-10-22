import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:myproject/models/routine_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoutineService {
  final String baseUrl = 'http://192.168.1.103:8080/api/routine';
  final Logger _logger = Logger();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); 
  } 

  // Fetch all routines
  Future<List<RoutineItem>> getAllRoutines() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      _logger.i(json.decode(response.body)); 
      List<RoutineItem> data = (json.decode(response.body) as List)
          .map((data) => RoutineItem.fromJson(data))
          .toList();
        return data;
    } else {
      throw Exception('Failed to load routines');
    }
  }

  // Add a new routine
  Future<RoutineItem> addRoutine(RoutineItem routine) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(routine.toJson()),
    );

    if (response.statusCode == 200) {
      return RoutineItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add routine');
    }
  }

  // Set routine as done
  Future<RoutineItem> setAsDone(int id) async {
    final token = await getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/done/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return RoutineItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update status');
    }
  }

  // Set routine as done
  Future<RoutineItem> setAsUndone(int id) async {
    final token = await getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/undone/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return RoutineItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update status');
    }
  }

  // Change time of a routine
  Future<RoutineItem> changeTime(int id, TimeOfDay time) async {
    final token = await getToken();
    final String formattedTime = '${time.hour}:${time.minute}';

    final response = await http.patch(
      Uri.parse('$baseUrl/change-time/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'time': formattedTime}),
    );

    if (response.statusCode == 200) {
      return RoutineItem.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update time');
    }
  }

  // Delete a routine
  Future<void> deleteRoutine(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete routine');
    }
  }
}
