import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myproject/models/appointement.dart';
import 'package:myproject/screens/event_details.dart';
import 'package:myproject/screens/journal_screen.dart';
import 'package:myproject/screens/locations_screen.dart';
import 'package:myproject/screens/people_screen.dart';
import 'package:myproject/screens/training_screen.dart';
import 'package:myproject/services/appointment_service.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late List<Appointment>_appointments;
  final AppointmentService _appointmentService = AppointmentService();
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _appointments = [];
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      List<Appointment> appointments = await _appointmentService.getByDate(DateTime.now());
      setState(() {
      //   for (var item in appointments) {
      //     if (item.time.hour>TimeOfDay.now().hour) {
      //       _appointments.add(item);
      //     }
      //   }
       _appointments = appointments;
      });
      _logger.i('appointments: ${_appointments[0].description}');
    } catch (e) {
      
      _logger.e('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5), // Ensure there's no padding at the top
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to start at the top
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search Section
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: _buildSearchSection(),
                ),
                const SizedBox(height: 15),

                // Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard('People To Remember', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PeopleScreen()),
                      );
                    }),
                    _buildSummaryCard('Important Locations', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LocationsScreen()),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard('Journals', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JournalScreen()),
                      );
                    }),
                    _buildSummaryCard('Trainning', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MemoryGameScreen()),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 15),

                // Upcoming Events Section
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: StyledSubheading('Upcoming Appointment'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _appointments[index];
                      return _buildEventCard(appointment);
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Announcements Section
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: StyledSubheading('Announcements'),
                ),
                const SizedBox(height: 10),
                _buildAnnouncement('General assembly meeting scheduled next week. Please RSVP.'),
                _buildAnnouncement('New training materials on irrigation are now available.'),
                const SizedBox(height: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the search section
  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search tasks, location, person...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(15.0),
        ),
        onChanged: (value) {
          // Implement search logic if needed
        },
      ),
    );
  }

  // Helper widget to build summary cards
  Widget _buildSummaryCard(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: 180,
          child: Center(child: StyledText(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }

  // Helper widget to build event cards
  Widget _buildEventCard(Appointment appointement) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.access_time, color:  Color.fromARGB(255, 194, 33, 243)),
        title: StyledText(appointement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: StyledText('${appointement.time}'),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(
                  appointment: appointement,
                ),
              ),
            );
          },
          child: const Text('details'),
        ),
      ),
    );
  }

  // Helper widget to build announcements
  Widget _buildAnnouncement(String announcement) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.announcement, color: Colors.orange),
        title: StyledText(announcement),
      ),
    );
  }
}

// Example Styled Text widgets used in your UI
class StyledHeading extends StatelessWidget {
  final String text;
  const StyledHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class StyledSubheading extends StatelessWidget {
  final String text;
  const StyledSubheading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class StyledText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const StyledText(this.text, {this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? const TextStyle(fontSize: 14),
    );
  }
}
