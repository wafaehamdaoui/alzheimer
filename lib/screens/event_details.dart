import 'package:flutter/material.dart';
import 'package:myproject/models/appointement.dart';
import 'package:myproject/services/appointment_service.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';

class EventDetailsPage extends StatefulWidget {
  final Appointment appointment;

  const EventDetailsPage({required this.appointment});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {

  final AppointmentService _appointmentService = AppointmentService();

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StyledTitle(widget.appointment.title),
        // actions: [
        //   IconButton(onPressed: ()=> deleteAppointment(widget.appointment), 
        //     icon: Icon(Icons.delete, color:  AppTheme.textColor,)
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                const Icon(Icons.calendar_month, color:  Color.fromARGB(255, 194, 33, 243)),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(widget.appointment.date.toIso8601String().split('T').first, style: const TextStyle(fontSize: 22)),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, color:  Color.fromARGB(255, 194, 33, 243)),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('${widget.appointment.time.hour}: ${widget.appointment.time.minute}', style: const TextStyle(fontSize: 22)),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.description, color:  Color.fromARGB(255, 194, 33, 243)),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Description: ${widget.appointment.description}', style: const TextStyle(fontSize: 22)),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
