import 'package:flutter/material.dart';

SnackBar customSnackBar({required String content, required Color textColor}) {
  return SnackBar(
    duration: Duration(milliseconds: 1000),
    backgroundColor: Colors.black,
    content: Text(
      content,
      style: TextStyle(color: textColor, letterSpacing: 0.5, fontSize: 20),
    ),
  );
}
