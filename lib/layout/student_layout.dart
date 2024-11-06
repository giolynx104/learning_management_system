import 'package:flutter/material.dart';
import 'package:learning_management_system/routes/router.dart';

class StudentLayout extends StatelessWidget {
  const StudentLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: studentRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}