import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myproject/models/journal.dart';
import 'package:shared_preferences/shared_preferences.dart';
class JournalService {
  final String baseUrl = 'https://alzheimerbackend.onrender.com/api/journals'; 

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); 
  } 
  Future<int> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id')??0; 
  } 

  // Method to get all journal entries
  Future<List<JournalEntry>> getAllJournals() async {
    final token = await getToken();
    final userId = await  getUserID();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'UserId': '$userId',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => JournalEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load journals');
    }
  }

  // Method to add a new journal entry
  Future<JournalEntry> addJournal(JournalEntry request) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()), // Assuming JournalRequest has a toJson method
    );

    if (response.statusCode == 200) {
      return JournalEntry.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add journal');
    }
  }

  // Method to delete a journal entry
  Future<void> deleteJournal(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete journal');
    }
  }
}
