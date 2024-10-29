import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myproject/models/task.dart';
import 'package:myproject/screens/task_details.dart';
import 'package:myproject/services/notification_service.dart';
import 'package:myproject/services/task_service.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Task> _tasks = [];
  bool _isLoading = true;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      _logger.d('Attempting to fetch tasks...');
      List<Task> tasks = await _taskService.getAllTasks();
      _logger.i('Tasks fetched successfully: $tasks'); 

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      if (this.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _logger.e('Error fetching tasks: $e', e, stackTrace); 
    }
  }
  Future<int> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id')??0; 
  } 

  void _addTask() async {
    final String taskTitle = _taskController.text;
    final String taskDescription = _descriptionController.text;
    final userId = await getUserID();
    if (taskTitle.isNotEmpty) {
      Task newTask = Task(title: taskTitle,description: taskDescription, date: _selectedDate, isDone: false, id: null, userId: userId);
      try {
        Task createdTask = await _taskService.addTask(newTask);
        setState(() {
          _tasks.add(createdTask);
          _taskController.clear();  
          _descriptionController.clear();  
          _selectedDate = DateTime.now();  
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StyledSuccessText('item_added_successfuly'.tr()), backgroundColor: Colors.white),
        );
        scheduleTaskReminder(taskTitle,_selectedDate);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StyledErrorText('Action_failed'.tr()), backgroundColor: Colors.white),
        );
        _logger.e('Error adding task: $e'); 
      }
    }
    Navigator.of(context).pop();  
  }


  void _toggleTaskCompletion(int index) async {
    if (_tasks[index].isDone) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('confirm'.tr(),style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.bold)),
          content: Text('complete_task'.tr()),
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
                  Task updatedTask = await _taskService.changeTaskStatus(_tasks[index].id);
                  setState(() {
                    _tasks[index] = updatedTask;
                  });
                  Navigator.of(context).pop(); // Close dialog
                } catch (e) {
                  // Handle error (e.g., show a message)
                }
              },
              child: Text('confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('confirm'.tr(),style: TextStyle(fontSize: 18, color: AppTheme.textColor, fontWeight: FontWeight.bold)),
          content: Text('confirm_delete_task'.tr()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _taskService.deleteTask(_tasks[index].id);
                  setState(() {
                    _tasks.removeAt(index);
                  });
                  Navigator.of(context).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: StyledSuccessText('Task_deleted_successfuly'.tr()), backgroundColor: Colors.white),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: StyledErrorText('Action_failed'.tr()), backgroundColor: Colors.white),
                  );
                  _logger.e('Error: $e'); 
                }
              },
              child: Text('confirm'.tr()),
            ),
          ],
        );
      },
    );
  }

  // Function to edit the task date
  void _editTaskDate(int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _tasks[index].date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _tasks[index].date) {
      try {
        Task updatedTask = await _taskService.changeTaskDate(_tasks[index].id, pickedDate);
        setState(() {
          _tasks[index] = updatedTask;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StyledSuccessText('Date_Updated_Successfuly'.tr()), backgroundColor: Colors.white),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: StyledErrorText('Action_failed'.tr()), backgroundColor: Colors.white),
        );
        _logger.e('Error : $e'); 
      }
    }
  }

 void _showAddTaskDialog() {
  showDialog(
    context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Add_New_Task',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textColor),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: 'title'.tr(),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description'.tr(),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "${'Selected_Date'.tr()}: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                  style: const TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: Text('Choose_Date'.tr()),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(// Set text color
              ),
              child: Text('add'.tr()),
            ),
          ],
        );
      },
    );
  }
  
  void scheduleTaskReminder(String title, DateTime dateTime) {
    var args = {'title': title};
    
    AndroidAlarmManager.oneShotAt(
      DateTime(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          08,
          00,),
      100, 
      _alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      params: args
    ).then((_) {
      _logger.d('Alarm scheduled for task: $title at $dateTime');
    }).catchError((error) {
      _logger.e('Failed to schedule alarm: $error');
    });
  }

  static Future<void> _alarmCallback(int id, Map<String, dynamic> args) async {
    final title = args['title'];
    final notificationService = NotificationService();
    notificationService.showNotification(
      111, 
      'You_have_Task_today'.tr(),
       title
    );
    Logger().d('Notification triggered');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 231, 201, 250),
        title: Center(child: Text('tasks'.tr())),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(child: Text('No_Entries'.tr()))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      color: task.isDone ? Colors.green[100] : Colors.white,
                      child: ListTile(
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(task.date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_calendar, size: 16),
                              onPressed: () => _editTaskDate(index), 
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new, size: 16),
                              onPressed: () => {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsPage(task: task),
                                  ),
                                )
                              }, 
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () => _deleteTask(index),
                            ),
                          ],
                        ),
                        onTap: () => _toggleTaskCompletion(index),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add_Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
