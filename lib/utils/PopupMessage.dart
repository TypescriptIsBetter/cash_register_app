
import 'package:flutter/material.dart';

/// Creates a simple popup with a title, message, and ok button
AlertDialog createPopupMessage(context, title, message) {
  return AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      OutlinedButton(
        child: new Text("OK", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.pop(context),
        style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            backgroundColor: MaterialStateProperty.all(Colors.blue)
        ),
      )
    ],
  );
}