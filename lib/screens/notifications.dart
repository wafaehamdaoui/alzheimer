import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr()), 
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Notification 1'),
            onTap: () {
              // context.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Notification 2'),
            onTap: () {
              // context.setLocale(const Locale('fr'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Notification 3'),
            onTap: () {
              // context.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}