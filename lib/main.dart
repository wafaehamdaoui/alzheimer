import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import Easy Localization
import 'package:myproject/screens/home.dart';
import 'package:myproject/screens/profile.dart';
import 'package:myproject/screens/sign_in.dart';
import 'package:myproject/screens/sign_up.dart';
import 'package:myproject/services/auth_service.dart';
import 'package:myproject/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')], // Supported languages
      path: 'assets/translations', 
      fallbackLocale: const Locale('en'), 
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: primarytheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, // Set the current locale

      home: FutureBuilder<bool>(
        future: _authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While checking the auth status, show a loading spinner
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Error occurred!')),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            // If the user is authenticated, navigate to the Home screen
            return const Home();
          } else {
            // If not authenticated, show SignIn screen
            return const SignIn();
          }
        },
      ),
      routes: {
        '/home': (context) => const Home(),
        '/sign-in': (context) => const SignIn(),
        '/sign-up': (context) => const SignUp(),
        '/profile': (context) => const ProfileScreen()
      },
    );
  }
}
