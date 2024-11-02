import 'package:flutter/material.dart';
import 'package:learning_management_system/routes/router.dart';

class TeacherLayout extends StatelessWidget {
  const TeacherLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: teacherRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}