import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myproject/models/appointement.dart';
import 'package:myproject/screens/event_details.dart';
import 'package:myproject/services/appointment_service.dart';
import 'package:myproject/services/notification_service.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final AppointmentService _appointmentService = AppointmentService();
  late Map<DateTime, List<Appointment>> _appointments;
  late List<Appointment> _selectedAppointments;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _appointments = {};
    _selectedAppointments = [];
    // Fetch appointments from the backend
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      List<Appointment> appointments = await _appointmentService.getAllAppointments();
       _logger.e('appointments: $appointments');
      setState(() {
        for (var appointment in appointments) {
          _addAppointmentToDay(appointment.date, appointment);
        }
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching tasks: $e', e, stackTrace); 
    }
  }

  // Method to get appointments for a particular day
  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final localDate = DateTime.utc(day.year, day.month, day.day);
    return _appointments[localDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getAppointmentsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _selectedAppointments = _getAppointmentsForDay(selectedDay);
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextStyle: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                daysOfWeekHeight: 40,
                locale: context.locale.toString(),
                calendarFormat: CalendarFormat.month,

                // Custom markers using CalendarBuilders
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, appointments) {
                    if (appointments.isNotEmpty) {
                      const maxMarkers = 4;
                      final displayAppointments = appointments.take(maxMarkers).toList();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: displayAppointments.map((appointment) {
                          Color markerColor = Colors.blue;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: markerColor,
                              shape: BoxShape.circle,
                            ),
                            width: 8.0,
                            height: 8.0,
                          );
                        }).toList(),
                      );
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16.0),
              Expanded(
                child: _buildAppointmentList(),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ElevatedButton(
              onPressed: _showAddAppointmentDialog,
              child: Text('add_appointment'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  showDialog(
    context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('add_appointment'.tr(), style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.bold))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'title'.tr()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'.tr()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date'.tr(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Time'.tr(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          // Format time in 24-hour format and update the TextField
                          final hour = pickedTime.hour.toString().padLeft(2, '0');
                          final minute = pickedTime.minute.toString().padLeft(2, '0');
                          timeController.text = '$hour:$minute';
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Validate date input
                  if (dateController.text.isEmpty) {
                    throw FormatException("Date cannot be empty");
                  }
                  
                  DateTime appointmentDate = DateTime.parse(dateController.text);

                  // Validate time input
                  if (timeController.text.isEmpty) {
                    throw FormatException("Time cannot be empty");
                  }

                  List<String> timeParts = timeController.text.split(':');

                  // Ensure the time has both hour and minute parts
                  if (timeParts.length != 2) {
                    throw FormatException("Invalid time format. Please use HH:mm.");
                  }

                  int hour = int.parse(timeParts[0]);
                  int minute = int.parse(timeParts[1]);

                  // Create a new appointment
                  final userId = await getUserID();
                  final newAppointment = Appointment(
                    id: null,
                    title: titleController.text,
                    description: descriptionController.text,
                    date: appointmentDate,
                    time: TimeOfDay(hour: hour, minute: minute),
                    userId: userId
                  );

                  await _appointmentService.addAppointment(newAppointment);
                  _addAppointmentToDay(appointmentDate, newAppointment);
                  scheduleAppointmentReminder(newAppointment.title, newAppointment.date, TimeOfDay(hour: hour, minute: minute));
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                  _logger.w(e);
                }
              },

              child: Text('add'.tr()),
            ),
            TextButton(
              onPressed:(){
                Navigator.of(context).pop();
              } , 
              child: Text('cancel'.tr()),)
          ],
        );
      },
    );
  }

  Future<int> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id')??0; 
  } 
  
  Future<void> _addAppointmentToDay(DateTime day, Appointment appointment) async {
    final localDate = DateTime.utc(day.year, day.month, day.day);
    
    if (_appointments[localDate] != null) {
      _appointments[localDate]!.add(appointment);
    } else {
      _appointments[localDate] = [appointment];
    }

    setState(() {
      _selectedAppointments = _getAppointmentsForDay(day);
    });
  }

  Future<void> _removeAppointmentToDay(DateTime day, Appointment appointment) async {
    final localDate = DateTime.utc(day.year, day.month, day.day);
    
    _appointments[localDate]!.remove(appointment);

    setState(() {
      _selectedAppointments = _getAppointmentsForDay(day);
    });
  }

  Future<int> getDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return int.parse((prefs.getString('notification_duration') ?? '1').split(' ').first);
  }

  void scheduleAppointmentReminder(String title, DateTime date, TimeOfDay time) async{
    DateTime scheduledTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    int duration = await getDuration();
    if (scheduledTime.isBefore(DateTime.now())) {
      _logger.e('The reminder time is in the past. Skipping alarm scheduling: $scheduledTime, now: ${DateTime.now()}');
      return; // Skip scheduling if time is in the past
    }

    var args = {'title': title, 'time': "${time.hour}:${time.minute}"};
    AndroidAlarmManager.oneShotAt(
      scheduledTime.subtract(Duration(minutes: duration)),
      101,
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      params: args,
    ).then((_) {
      _logger.d('Alarm scheduled for appointment: $title at $scheduledTime');
    }).catchError((error) {
      _logger.e('Failed to schedule alarm: $error');
    });
  }

  static Future<void> _alarmCallback(int id, Map<String, dynamic> args) async {
    final title = args['title'];
    final time = args['time'];
    final notificationService = NotificationService();
    notificationService.showNotification(
      110, 
      '${'appointment_notif'.tr()} $time',
       title
    );
    Logger().d('Notification triggered');
  }

  Widget _buildAppointmentList() {
    return ListView.builder(
      // shrinkWrap: true,
      // physics: NeverScrollableScrollPhysics(),
      itemCount: _selectedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = _selectedAppointments[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 3),
                blurRadius: 6.0,
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            leading: const Icon(
              Icons.event,
              color: Colors.orangeAccent,
              size: 30.0,
            ),
            title: Text(
              appointment.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                TextButton(
                  onPressed: () { 
                    Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailsPage(appointment: appointment),
                      ),
                    );
                  },
                  child: const Icon(Icons.open_in_new, size: 20),
                ),
                TextButton(
                  onPressed: () => deleteAppointment(appointment),
                  child: const Icon(Icons.delete, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
   void deleteAppointment(Appointment appointment) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('confirm'.tr(), style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.bold)),
          content: Text('confirm_delete_appointment'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _appointmentService.deleteAppointment(appointment.id??0);
                  _removeAppointmentToDay(appointment.date, appointment);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: StyledSuccessText('Appointment_deleted_successfuly'.tr()), backgroundColor: Colors.white),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: StyledErrorText('Action_failed'.tr()), backgroundColor: Colors.white),
                  );
                }
              },
              child: Text('confirm'.tr()),
            ),
          ],
        );
      },
    );
  }


  
}
