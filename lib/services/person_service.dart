import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person.dart';
import '../models/api_response.dart';  // Assuming you have an API response model to handle response status and errors

class PersonService {
  static const String _baseUrl = 'http://192.168.1.103:8080/api/people'; 
  
  // Retrieve the token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Retrieve the token
  }

  // Fetch all people
  Future<List<Person>> getAllPeople() async {
    final token = await getToken();
    final response = await http.get(Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Person> people = body.map((dynamic item) => Person.fromJson(item)).toList();
      return people;
    } else {
      throw Exception('Failed to load people');
    }
  }

  // Add a new person
  Future<ApiResponse> addPerson(Person person) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(_baseUrl),
      body: jsonEncode(person.toJson()),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body)); // Assuming you have an ApiResponse model
    } else {
      throw Exception('Failed to add person');
    }
  }

  // Delete a person by ID
  Future<void> deletePerson(int id) async {
    final token = await getToken();
    final url = '$_baseUrl/$id';
    final response = await http.delete(Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete person');
    }
  }
}