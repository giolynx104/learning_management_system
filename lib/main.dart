import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_management_system/layout/student_layout.dart';
import 'package:learning_management_system/layout/teacher_layout.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StudentLayout(),
      debugShowCheckedModeBanner: false,
      title: 'Learning Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red[900]!,
          primary: Colors.red[900]!,
          onPrimary: Colors.white,
        ),
        useMaterial3: true,
      ),
    );
  }
}
