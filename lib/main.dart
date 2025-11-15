import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager (Back4App REST)',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
