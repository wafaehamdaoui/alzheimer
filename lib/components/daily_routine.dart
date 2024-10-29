import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myproject/services/notification_service.dart';
import 'package:myproject/services/routine_service.dart';
import 'package:myproject/models/routine_item.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'confirmation_dialog.dart'; 

Future<List<RoutineItem>> resetRoutineStatus() async {
  final RoutineService routineService = RoutineService();
  List<RoutineItem> routines = await routineService.getAllRoutines();
  

  for (var routine in routines) {
    if (routine.isDone) {
      await routineService.setAsUndone(routine.id ?? 0);
    }
  }

  Logger().i("All routines have been reset.");
  return routines;
}

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({super.key});

  @override
  State<DailyRoutineScreen> createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  final RoutineService _routineService = RoutineService();
  final List<RoutineItem> _dailyRoutine = [];
  final TextEditingController _titleController = TextEditingController();
  String _selectedCategory = 'medicine'; 
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = true;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadRoutinesFromBackend(); 
    _scheduleMinuteReset();
    _selectedCategory = 'medicine';
  }

  // Fetch routines from the backend
  Future<void> _loadRoutinesFromBackend() async {
    try {
      List<RoutineItem> routines = await _routineService.getAllRoutines();
      setState(() {
        _dailyRoutine.clear();
        _dailyRoutine.addAll(routines);
        _isLoading = false;
      });
      _logger.i('Routine loaded by success!');
    } catch (e) {
      if (this.mounted) {
        setState(() {
          setState(() {
            _isLoading = false;
          });
        });
      }
      _logger.e('$e');
    }
  }
  
  Future<int> getDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return int.parse((prefs.getString('notification_duration') ?? '1').split(' ').first);
  }
  Future<int> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id')??0; 
  } 
  
  Future<void> _addRoutineItem() async {
    final String itemTitle = _titleController.text;
    final userId = await getUserID();
    if (itemTitle.isNotEmpty) {
      RoutineItem newItem = RoutineItem(
        id: null,
        title: itemTitle,
        category: _selectedCategory,
        time: _selectedTime,
        isDone: false,
        userId: userId
      );
      try {
        RoutineItem addedRoutine = await _routineService.addRoutine(newItem);
        setState(() {
          _dailyRoutine.add(addedRoutine);
          _titleController.clear();
        });
        Navigator.of(context).pop();
        
        DateTime now = DateTime.now();
        int duration = await getDuration();
        DateTime routineDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ).subtract(Duration(minutes: duration)); 
        scheduleDailyAlarm(itemTitle, routineDateTime);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StyledSuccessText('item_added_successfuly'.tr()), backgroundColor: Colors.white),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action_failed'.tr())),
        );
      }
    }
  }

  void scheduleDailyAlarm(String title, DateTime dateTime)async {
    int duration = await getDuration();
    var args = {'title': title, 'time': duration };
    AndroidAlarmManager.periodic(
      const Duration(hours: 24),
      10,
      _alarmCallback,
      startAt: dateTime,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      params: args
    ).then((_) {
      _logger.d('Alarm scheduled for task: $title at $dateTime');
    }).catchError((error) {
      _logger.e('args: $args');
      _logger.e('Failed to schedule alarm: $error');
    });
  }

  static Future<void> _alarmCallback(int id, Map<String, dynamic> args) async {
  final title = args['title'];
  final duration = args['time']; 
  final notificationService = NotificationService();
  try {
    notificationService.showNotification(
      11, 
      '${'Routine_to_complete'.tr()} $duration minutes.',
       title
    );
    Logger().d('Notification triggered: ${args['title']}, ${args['time']}');
  } catch (e) {
    Logger().d('Notification failed: ${args['title']}, ${args['time']}');
    Logger().e('Notification failed: $e');
  }
}

  // Delete a routine from the backend
  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Confirm_Deletion'.tr(),
          content: '${'Are_you_sure'.tr()} ${_dailyRoutine[index].title}?',
          onConfirm: () async {
            try {
              await _routineService.deleteRoutine(_dailyRoutine[index].id ?? 0); 
              setState(() {
                _dailyRoutine.removeAt(index);
              });
              Navigator.of(context).pop(); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Center(child: StyledSuccessText('Routine_deleted_by_success'.tr())), backgroundColor: Colors.white),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Center(child: StyledErrorText('Action_failed'.tr())), backgroundColor: Colors.white),
                  );
              _logger.e('$e');
            }
          },
        );
      },
    );
  }

  // Mark routine as done and update on the backend
  void _markAsDone(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'confirm'.tr(),
          content: '${'Did_you_really_complete'.tr()} ${_dailyRoutine[index].title}?',
          onConfirm: () async {
            try {
              RoutineItem updatedRoutine = await _routineService.setAsDone(_dailyRoutine[index].id ?? 0);
              setState(() {
                _dailyRoutine[index] = updatedRoutine;
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          },
        );
      },
    );
  }

  // Update the time of a routine on the backend
  void _updateTime(int index) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      TimeOfDay newTime = TimeOfDay(
        hour: pickedTime.hour,
        minute: pickedTime.minute,
      );
      try {
        RoutineItem updatedRoutine = await _routineService.changeTime(_dailyRoutine[index].id ?? 0, newTime);
        setState(() {
          _dailyRoutine[index] = updatedRoutine;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

   // Show dialog to add a new routine item
 void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Add_New_Routine_Item'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Input
              SizedBox(
                width: double.infinity, 
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'title'.tr(),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), 

              // Dropdown Button
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  value: _selectedCategory,
                  hint: Text(
                    'select_category'.tr(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  items: [
                    DropdownMenuItem(value: 'medicine', child: Text('medicine'.tr())),
                    DropdownMenuItem(value: 'exercise', child: Text('exercise'.tr())),
                    DropdownMenuItem(value: 'task', child: Text('task'.tr())),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.purple,
                  iconSize: 24.0,
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: 10),
              Text("${'selected_time'.tr()}: ${_selectedTime.hour}:${_selectedTime.minute}"),
              TextButton(
                onPressed: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = TimeOfDay(
                        hour: pickedTime.hour,
                        minute: pickedTime.minute,
                      );
                    });
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: Text('choose_time'.tr()),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: _addRoutineItem,
              child: Text('add'.tr()),
            ),
          ],
        );
      },
    );
  }

  // Schedule routine reset every minute
  void _scheduleMinuteReset() async {
    await AndroidAlarmManager.periodic(
      const Duration(hours: 24), 
      0, // Unique alarm ID
      resetRoutineStatus, 
      startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0),
      exact: true,
      wakeup: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 231, 201, 250),
        title: Center(child: Text('daily_routine'.tr())),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dailyRoutine.isEmpty
          ? Center(child: Text('No_Entries'.tr()))
          : ListView.builder(
              itemCount: _dailyRoutine.length,
              itemBuilder: (context, index) {
                final item = _dailyRoutine[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  color: item.isDone ? Colors.green[100] : Colors.white,
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: item.isDone ? Colors.green : Colors.grey,),
                      onPressed: item.isDone ? null : () => _markAsDone(index),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: item.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text("${item.category} - ${item.time.hour}:${item.time.minute}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _deleteItem(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add_Routine_Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
