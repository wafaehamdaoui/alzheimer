import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late Locale _selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLocale = context.locale; 
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _selectedLocale = locale;
    });
    context.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('select_language'.tr()),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Radio<Locale>(
              value: const Locale('en'),
              groupValue: _selectedLocale,
              onChanged: (Locale? value) {
                if (value != null) _changeLanguage(value);
              },
            ),
            title: const Text('English'),
            onTap: () => _changeLanguage(const Locale('en')),
          ),
          ListTile(
            leading: Radio<Locale>(
              value: const Locale('ar'),
              groupValue: _selectedLocale,
              onChanged: (Locale? value) {
                if (value != null) _changeLanguage(value);
              },
            ),
            title: const Text('العربية'),
            onTap: () => _changeLanguage(const Locale('ar')),
          ),
        ],
      ),
    );
  }
}
