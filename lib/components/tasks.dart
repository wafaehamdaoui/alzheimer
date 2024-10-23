import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:myproject/models/task.dart';
import 'package:myproject/services/task_service.dart';
import 'package:myproject/shared/styled_text.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  final TextEditingController _taskController = TextEditingController();
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
      setState(() {
        _isLoading = false;
      });
      _logger.e('Error fetching tasks: $e', e, stackTrace); 
    }
  }

  void _addTask() async {
    final String taskTitle = _taskController.text;
    if (taskTitle.isNotEmpty) {
      Task newTask = Task(title: taskTitle, date: _selectedDate, isDone: false, id: null);
      try {
        Task createdTask = await _taskService.addTask(newTask);
        setState(() {
          _tasks.add(createdTask);
          _taskController.clear();  
          _selectedDate = DateTime.now();  // Reset the date selection
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: StyledSuccessText('Task added successfuly!'), backgroundColor: Colors.white),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: StyledErrorText('Action failed!'), backgroundColor: Colors.white),
        );
        _logger.e('Error adding task: $e'); 
      }
    }
    Navigator.of(context).pop();  // Close the dialog
  }


  void _toggleTaskCompletion(int index) async {
    if (_tasks[index].isDone) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Did you actually complete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
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
              child: const Text('Yes'),
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
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _taskService.deleteTask(_tasks[index].id);
                  setState(() {
                    _tasks.removeAt(index);
                  });
                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: StyledSuccessText('Task deleted successfuly!'), backgroundColor: Colors.white),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: StyledErrorText('Action failed!'), backgroundColor: Colors.white),
                  );
                  _logger.e('Error: $e'); 
                }
              },
              child: const Text('Yes'),
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _tasks[index].date) {
      try {
        Task updatedTask = await _taskService.changeTaskDate(_tasks[index].id, pickedDate);
        setState(() {
          _tasks[index] = updatedTask;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: StyledSuccessText('Date Updated Successfuly!'), backgroundColor: Colors.white),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: StyledErrorText('Action failed!'), backgroundColor: Colors.white),
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
        title: const Text(
          'Add New Task',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Task title',
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
                "Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
                style: TextStyle(fontSize: 16),
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
                child: const Text('Choose Date'),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: const Text('Add'),
            style: ElevatedButton.styleFrom(// Set text color
            ),
          ),
        ],
      );
    },
  );
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
              ? const Center(child: Text('No entries yet.'))
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
                              icon: const Icon(Icons.edit, size: 15),
                              onPressed: () => _editTaskDate(index), // Edit date
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 15),
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
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
