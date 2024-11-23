import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'package:learning_management_system/services/attendance_service.dart';
import 'package:learning_management_system/models/attendance_model.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class RollCallActionScreen extends HookConsumerWidget {
  final String classId;

  const RollCallActionScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = useState(false);
    final students = useState<List<Student>>(
      List.generate(
        30,
        (index) => Student(
          name: 'Student ${index + 1}',
          id: 'S${(index + 1).toString().padLeft(3, '0')}',
          isPresent: true,
        ),
      ),
    );
    final showOnlyAbsent = useState(false);

    return Scaffold(
      body: Column(
        children: [
          // ... rest of your implementation
        ],
      ),
    );
  }
}

class Student {
  final String name;
  final String id;
  bool isPresent;

  Student({
    required this.name,
    required this.id,
    required this.isPresent,
  });
}

class ClassInfo {
  final String name;
  final String id;
  final int totalStudents;

  const ClassInfo({
    required this.name,
    required this.id,
    required this.totalStudents,
  });
}
