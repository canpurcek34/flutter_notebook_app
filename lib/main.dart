import 'package:flutter/material.dart';
import 'package:notebook_app/authpages/authScreen.dart';
import 'package:notebook_app/ui/notebook_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Notebook App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthScreen(), // Ana ekran olarak NotebookScreen'i ayarlayın
    );
  }
}
