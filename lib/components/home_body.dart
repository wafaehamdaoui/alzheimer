import 'package:easy_localization/easy_localization.dart';
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
      padding: EdgeInsets.all(5), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
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
                    _buildSummaryCard('people'.tr(), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PeopleScreen()),
                      );
                    }),
                    _buildSummaryCard('locations'.tr(), () {
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
                    _buildSummaryCard('journals'.tr(), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JournalScreen()),
                      );
                    }),
                    _buildSummaryCard('trainning'.tr(), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MemoryGameScreen()),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 15),

                // Upcoming Events Section
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: StyledSubheading('upcoming_appointment'.tr()),
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
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: StyledSubheading('helpful_advice'.tr()),
                ),
                const SizedBox(height: 10),
                _buildAnnouncement('adv2'.tr()),
                _buildAnnouncement('adv5'.tr()),
                _buildAnnouncement('adv7'.tr()),
                _buildAnnouncement('adv3'.tr()),
                _buildAnnouncement('adv4'.tr()),
                _buildAnnouncement('adv1'.tr()),
                _buildAnnouncement('adv6'.tr()),
                const SizedBox(height: 10),
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
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: 'search_text'.tr(),
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(15.0),
        ),
        onChanged: (value) {
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
          width: 175,
          child: Center(child: StyledText(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
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
        subtitle: StyledText('Today - ${appointement.time.hour}:${appointement.time.minute}'),
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
          child: Text('Details'.tr()),
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
