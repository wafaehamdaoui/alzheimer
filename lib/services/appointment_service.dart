import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:myproject/models/appointement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  final String baseUrl = 'https://alzheimerbackend.onrender.com/api/appointments'; 
  final Logger _logger = Logger();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); 
  } 

  // Fetch all appointments
  Future<List<Appointment>> getAllAppointments() async {
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
      List<Appointment> appointements = (json.decode(response.body) as List)
          .map((data) => Appointment.fromJson(data))
          .toList();
      return appointements;
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  // Add a new appointment
  Future<Appointment> addAppointment(Appointment appointment) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(appointment.toJson()),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add appointment');
    }
  }

  // Fetch appointments by date
  Future<List<Appointment>> getByDate(DateTime date) async {
    final token = await getToken();
    try {
      // Format date to ISO 8601 string (yyyy-MM-dd)
      String formattedDate = date.toIso8601String().substring(0, 10); 
      final response = await http.get(
        Uri.parse('$baseUrl/$formattedDate'),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Appointment.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load appointments for the date: $formattedDate');
      }
    } catch (e) {
      throw Exception('Failed to fetch appointments for the date: $e');
    }
  }

  // Delete an appointment by id
  Future<void> deleteAppointment(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete appointment');
    }
  }
}
