import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, { required String text, int duration = 1 }) {
  final SnackBar snackBar = SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}