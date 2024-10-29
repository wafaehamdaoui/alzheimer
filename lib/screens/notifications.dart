import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final List<String> timeOptions = [
    '1_minutes'.tr(),
    '5_minutes'.tr(),
    '10_minutes'.tr(),
    '30_minutes'.tr(),
    '60_minutes'.tr(),
  ];

  String? _selectedOption; 

  @override
  void initState() {
    super.initState();
    _saveDuration(timeOptions[1]);
    _loadDuration(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification_Settings'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text prompt
              Text(
              'choose_duration'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16), 
            Expanded(
              child: ListView.builder(
                itemCount: timeOptions.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    title: Text(timeOptions[index]),
                    value: timeOptions[index],
                    groupValue: _selectedOption, 
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value; 
                      });
                      _saveDuration(value!); 
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDuration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption = prefs.getString('notification_duration'); 
    });
  }

  Future<void> _saveDuration(String option) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_duration', option);
  }
}
