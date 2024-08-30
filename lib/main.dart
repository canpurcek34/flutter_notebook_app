import 'package:flutter/material.dart';
import 'notebook_screen.dart';

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
      home: NotebookScreen(), // Ana ekran olarak NotebookScreen'i ayarlayın
    );
  }
}
