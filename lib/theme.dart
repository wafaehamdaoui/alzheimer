import 'package:flutter/material.dart';

class AppTheme {
  static Color primaryColor = Color.fromARGB(255, 61, 21, 81);
  static Color primaryAccent = Color.fromARGB(255, 139, 32, 188);
  static Color secondaryColor = Color.fromARGB(255, 101, 72, 115);
  static Color focusColor = const Color.fromARGB(255, 240, 215, 142);
  static Color boxColor = Color.fromARGB(255, 231, 201, 250);
  static Color textColor = Color.fromARGB(255, 77, 27, 94);
}

ThemeData primarytheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
  scaffoldBackgroundColor: AppTheme.boxColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: AppTheme.textColor,
      fontSize: 16,
    ),
    headlineMedium: TextStyle(
      color: AppTheme.textColor,
      fontSize: 16,
      //fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: AppTheme.textColor,
      //fontWeight: FontWeight.bold,
      fontSize: 25,
    ),
    headlineSmall: const TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    labelMedium: const TextStyle(
      color: Colors.red,
      fontSize: 16,
    ),
    labelSmall: const TextStyle(
      color: Colors.green,
      fontSize: 16,
    ),
  )
);