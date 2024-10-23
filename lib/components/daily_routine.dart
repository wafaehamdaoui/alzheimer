import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myproject/services/routine_service.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/models/routine_item.dart';
import 'package:myproject/theme.dart';
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
  String _selectedCategory = 'medicine'; // Default category
  TimeOfDay _selectedTime = TimeOfDay.now();
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
      });
      _logger.i('Routine loaded by success!');
    } catch (e) {
      _logger.e('$e');
    }
  }

  // Add a new routine to the backend
  Future<void> _addRoutineItem() async {
    final String itemTitle = _titleController.text;
    if (itemTitle.isNotEmpty) {
      RoutineItem newItem = RoutineItem(
        id: null,
        title: itemTitle,
        category: _selectedCategory,
        time: _selectedTime,
        isDone: false,
      );
      try {
        RoutineItem addedRoutine = await _routineService.addRoutine(newItem);
        setState(() {
          _dailyRoutine.add(addedRoutine);
          _titleController.clear();
        });
        Navigator.of(context).pop(); // Close dialog
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  // Delete a routine from the backend
  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Confirm Deletion',
          content: 'Are you sure you want to delete ${_dailyRoutine[index].title}?',
          onConfirm: () async {
            try {
              await _routineService.deleteRoutine(_dailyRoutine[index].id ?? 0); // Call delete from service
              setState(() {
                _dailyRoutine.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Routine deleted by success!'), backgroundColor: Colors.white),
              );
            } catch (e) {
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
          title: 'Confirm Completion',
          content: 'Did you really complete ${_dailyRoutine[index].title}?',
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
          title: const Text('Add New Routine Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration:InputDecoration(labelText: 'Routine title',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                underline: SizedBox(), // Remove underline
                hint: const Text(
                  'Select a Category',
                  style: TextStyle(color: Colors.grey),
                ),
                items: const [
                  DropdownMenuItem(value: 'medicine', child: Text('Medicine')),
                  DropdownMenuItem(value: 'exercise', child: Text('Exercise')),
                  DropdownMenuItem(value: 'task', child: Text('Task')),
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
                dropdownColor: Colors.white, // Background color of dropdown
                iconEnabledColor: Colors.purple, // Dropdown icon color
                iconSize: 24.0,
              ),
              const SizedBox(height: 10),
              Text("Selected Time: ${_selectedTime.hour}:${_selectedTime.minute}"),
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
                child: const Text('Choose Time'),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addRoutineItem,
              child: const Text('Add'),
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
        title: const Center(child: StyledTitle('Daily Routine')),
      ),
      body: _dailyRoutine.isEmpty
          ? const Center(child: Text('No Entries Yet!'))
          : ListView.builder(
              itemCount: _dailyRoutine.length,
              itemBuilder: (context, index) {
                final item = _dailyRoutine[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  color: item.isDone ? Colors.green[100] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      item.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: item.isDone ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: item.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text("${item.category} - ${item.time}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => _deleteItem(index),
                    ),
                    onTap: item.isDone ? null : () => _markAsDone(index), // Disable tap if item is done
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Add Routine Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
