import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:myproject/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  final String apiUrl = 'http://192.168.1.103:8080/api/tasks';
  final Logger _logger = Logger();

  // Retrieve the token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); 
  } 

  Future<List<Task>> getAllTasks() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      _logger.w(json.decode(response.body)); 
      List<Task> tasks = (json.decode(response.body) as List)
          .map((data) => Task.fromJson(data))
          .toList();
          
      return tasks;
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> addTask(Task request) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add task');
    }
  }

  Future<Task> changeTaskStatus(int? id) async {
    final token = await getToken();
    final response = await http.patch(
      Uri.parse('$apiUrl/change-status/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update task status');
    }
  }

  Future<Task> changeTaskDate(int? id, DateTime newDate) async {
    final token = await getToken();
    _logger.i(newDate.toIso8601String().split('T').first); 
    final response = await http.patch(
      Uri.parse('$apiUrl/change-date/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"date": newDate.toIso8601String().split('T').first}),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to change task date');
    }
  }

  Future<void> deleteTask(int? id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}

