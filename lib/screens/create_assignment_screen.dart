import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/services/notification_service.dart';
import 'package:learning_management_system/models/notification_model.dart';
import 'package:learning_management_system/widgets/file_upload_widget.dart';
import 'package:learning_management_system/constants/file_upload_configs.dart';

class CreateAssignmentScreen extends ConsumerStatefulWidget {
  final String classId;
  const CreateAssignmentScreen({super.key, required this.classId});

  @override
  CreateAssignmentScreenState createState() => CreateAssignmentScreenState();
}

class CreateAssignmentScreenState extends ConsumerState<CreateAssignmentScreen> {
  final TextEditingController _assignmentNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _endDateTime;
  PlatformFile? _selectedFile;
  bool _isSubmitEnabled = false;
  bool _isLoading = false;

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
        body: Stack(
          children: [
            SingleChildScrollView(
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
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    FileUploadWidget(
                      config: FileUploadConfigs.assignment,
                      selectedFiles: _selectedFile != null ? [_selectedFile!] : [],
                      isLoading: _isLoading,
                      onFilesSelected: (files) {
                        setState(() {
                          _selectedFile = files.first;
                        });
                        _validateForm();
                      },
                      onFileRemoved: (_) {
                        setState(() {
                          _selectedFile = null;
                        });
                        _validateForm();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimeSelector(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isSubmitEnabled && !_isLoading) ? _createAssignment : null,
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Creating...'),
                                ],
                              )
                            : const Text('Create Assignment'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return InkWell(
      onTap: _isLoading ? null : () => _selectDateTime(context),
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
    if (!_isSubmitEnabled) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      if (authState.token == null) {
        throw Exception('Not authenticated');
      }

      debugPrint('Creating assignment with:');
      debugPrint('Title: ${_assignmentNameController.text}');
      debugPrint('Description: ${_descriptionController.text}');
      debugPrint('Deadline: $_endDateTime');
      debugPrint('File: ${_selectedFile?.name}');
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
        setState(() {
          _isLoading = false;
        });
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
