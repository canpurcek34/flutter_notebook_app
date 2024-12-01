import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notebook_app/ui/Notebook.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'authpages/AuthScreen.dart';
import 'authpages/LoginScreen.dart';
import 'authpages/SignScreen.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Authentication',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthScreen(),
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/notebook': (context) => NotebookScreen(),
      },
    );
  }
}
