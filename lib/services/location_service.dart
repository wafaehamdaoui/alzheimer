import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:myproject/models/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final String baseUrl = 'http://192.168.1.103:8080/api/locations';
  final Logger _logger = Logger();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); 
  } 


  // Fetch all locations
  Future<List<Location>> getAllLocations() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((location) => Location.fromJson(location)).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // Add a new location
  Future<Location> addLocation(Location location) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(location.toJson()),
    );

    if (response.statusCode == 200) {
      return Location.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add location');
    }
  }

  // Delete a location by ID
  Future<void> deleteLocation(int id) async {
    _logger.w("id=$id");
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete location');
    }
  }
}
