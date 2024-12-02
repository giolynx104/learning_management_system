import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/services/notification_service.dart';
import 'package:learning_management_system/models/notification_model.dart';

class CreateAssignmentScreen extends ConsumerStatefulWidget {
  final String classId;
  const CreateAssignmentScreen({super.key, required this.classId});

  @override
  CreateAssignmentScreenState createState() => CreateAssignmentScreenState();
}

class CreateAssignmentScreenState
    extends ConsumerState<CreateAssignmentScreen> {
  final TextEditingController _assignmentNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _endDateTime;
  PlatformFile? _selectedFile;
  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _assignmentNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isSubmitEnabled = _assignmentNameController.text.isNotEmpty &&
          _endDateTime != null;
    });
    debugPrint('Form validation: isEnabled=$_isSubmitEnabled, title=${_assignmentNameController.text}, deadline=$_endDateTime');
  }

  @override
  void dispose() {
    _assignmentNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Assignment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _assignmentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Assignment Name *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _validateForm(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text(_selectedFile?.name ?? 'Upload File (Optional)'),
                ),
                const SizedBox(height: 16),
                _buildDateTimeSelector(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitEnabled ? _createAssignment : null,
                  child: const Text('Create Assignment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
      _validateForm();
    }
  }

  Widget _buildDateTimeSelector() {
    return InkWell(
      onTap: () => _selectDateTime(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Deadline *',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _formatDateTime(_endDateTime),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null && context.mounted) {
        setState(() {
          _endDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        _validateForm();
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    return dateTime == null
        ? 'Select Deadline'
        : DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _createAssignment() async {
    if (_assignmentNameController.text.isEmpty) {
      _showSnackBar('Please enter an assignment name');
      return;
    }

    if (_endDateTime == null) {
      _showSnackBar('Please select a deadline');
      return;
    }

    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }

      debugPrint('=== Auth Token Debug Info ===');
      debugPrint('Token: ${authState.token}');
      debugPrint('==========================');

      final assignmentService = ref.read(assignmentServiceProvider.notifier);
      await assignmentService.createAssignment(
        token: authState.token!,
        classId: widget.classId,
        title: _assignmentNameController.text.trim(),
        deadline: DateFormat('yyyy-MM-ddTHH:mm:ss').format(_endDateTime!),
        description: _descriptionController.text.trim(),
        file: _selectedFile,
      );

      // Send notifications to all students in the class
      final classService = ref.read(classServiceProvider.notifier);
      final classInfo = await classService.getClassDetail(
        token: authState.token!,
        classId: widget.classId,
      );

      if (classInfo != null) {
        final notificationService = ref.read(notificationServiceProvider.notifier);
        final title = 'New Assignment: ${_assignmentNameController.text.trim()}';
        final message = 'A new assignment has been created for your class: ${classInfo.className}\n'
            'Deadline: ${DateFormat('dd/MM/yyyy HH:mm').format(_endDateTime!)}';

        for (final student in classInfo.studentAccounts) {
          try {
            await notificationService.sendNotification(
              authState.token!,
              message,
              student.accountId,
              NotificationType.assignmentGrade,
              null,
            );
          } catch (e) {
            debugPrint('Failed to send notification to student ${student.accountId}: $e');
          }
        }
      }

      if (mounted) {
        _showSnackBar('Assignment created successfully');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error creating assignment: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
