import 'package:flutter/material.dart';

Color blackColor = Color.fromARGB(255, 40, 43, 48);
Color textColor = Colors.white;
Color baseColor = Color.fromARGB(
    255, 242, 145, 27); // Colors.blueAccent.shade400.withOpacity(0.8);

ThemeData baseTheme = ThemeData(
  colorSchemeSeed: baseColor,
  scaffoldBackgroundColor: blackColor,
  textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
      bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
      bodySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w300)),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) => blackColor),
    ),
  ),
  useMaterial3: true,
);
