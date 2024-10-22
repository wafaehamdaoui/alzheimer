import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('select_language'.tr()),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () {
              context.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Français'),
            onTap: () {
              context.setLocale(const Locale('fr'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('العربية'),
            onTap: () {
              context.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
