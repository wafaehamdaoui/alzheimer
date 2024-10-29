import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:myproject/models/task.dart';
import 'package:myproject/services/task_service.dart';
import 'package:myproject/shared/styled_text.dart';
import 'package:myproject/theme.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;

  const TaskDetailsPage({required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {

  final TaskService taskService = TaskService();

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StyledTitle(widget.task.title),
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
                  child: Text(widget.task.date.toIso8601String().split('T').first, style: const TextStyle(fontSize: 22)),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.description, color: Color.fromARGB(255, 194, 33, 243)),
                Text('Description'.tr(), style: TextStyle(fontSize: 22,color: AppTheme.primaryAccent))
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 10),
                child: Text(
                  widget.task.description,
                  style: const TextStyle(fontSize: 21),
                  softWrap: true, 
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
