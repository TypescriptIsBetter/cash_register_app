import 'package:cash_register_app/Register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cash Register",
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: Register()
    );
  }
}