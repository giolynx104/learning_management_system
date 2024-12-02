import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/services/notification_service.dart';
import 'package:learning_management_system/models/notification_model.dart';

class EditAssignmentScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  final Assignment assignment;

  const EditAssignmentScreen({
    super.key,
    required this.assignmentId,
    required this.assignment,
  });

  @override
  EditAssignmentScreenState createState() => EditAssignmentScreenState();
}

class EditAssignmentScreenState extends ConsumerState<EditAssignmentScreen> {
  final TextEditingController _assignmentNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _endDateTime;
  PlatformFile? _selectedFile;
  bool _isSubmitEnabled = false;
  String? _currentFileUrl;

  @override
  void initState() {
    super.initState();
    _assignmentNameController.text = widget.assignment.title;
    _descriptionController.text = widget.assignment.description ?? '';
    _endDateTime = widget.assignment.deadline;
    _currentFileUrl = widget.assignment.fileUrl;

    _assignmentNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      final isNameNotEmpty = _assignmentNameController.text.isNotEmpty;
      final isDeadlineSet = _endDateTime != null;
      final hasChanges = _assignmentNameController.text != widget.assignment.title ||
          _descriptionController.text != (widget.assignment.description ?? '') ||
          _selectedFile != null ||
          (_endDateTime?.isAtSameMomentAs(widget.assignment.deadline) == false);

      _isSubmitEnabled = isNameNotEmpty && isDeadlineSet && hasChanges;
    });
  }

  @override
  void dispose() {
    _assignmentNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Assignment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _assignmentNameController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Name *',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Enter assignment description',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDateTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Deadline *',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _endDateTime == null
                            ? 'Select Deadline'
                            : DateFormat('dd/MM/yyyy HH:mm').format(_endDateTime!),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_currentFileUrl != null && _selectedFile == null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: const Text('Current File'),
                    subtitle: Text(_currentFileUrl!.split('/').last),
                  ),
                ),
              const SizedBox(height: 8),
              if (_selectedFile != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('New File Selected'),
                    subtitle: Text(_selectedFile!.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _selectedFile = null;
                        _validateForm();
                      }),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile == null ? 'Select File' : 'Change File'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSubmitEnabled ? _handleSubmit : null,
                child: const Text('Update Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
      _validateForm();
    }
  }

  Future<void> _handleSubmit() async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) throw Exception('Not authenticated');

      final assignmentService = ref.read(assignmentServiceProvider.notifier);
      await assignmentService.editAssignment(
        token: authState.token!,
        assignmentId: widget.assignmentId,
        title: _assignmentNameController.text.trim(),
        deadline: DateFormat('yyyy-MM-ddTHH:mm:ss').format(_endDateTime!),
        description: _descriptionController.text.trim(),
        file: _selectedFile,
      );

      // Send notifications to all students in the class
      final classService = ref.read(classServiceProvider.notifier);
      final classInfo = await classService.getClassDetail(
        token: authState.token!,
        classId: widget.assignment.classId,
      );

      if (classInfo != null) {
        final notificationService = ref.read(notificationServiceProvider.notifier);
        final message = 'Assignment "${_assignmentNameController.text.trim()}" has been updated.\n'
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating assignment: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
} 