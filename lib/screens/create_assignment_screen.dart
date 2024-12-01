import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/providers/assignment_provider.dart';
import 'package:learning_management_system/services/assignment_service.dart';

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
          (_descriptionController.text.isNotEmpty || _selectedFile != null);
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _assignmentNameController,
                  decoration: const InputDecoration(
                    labelText: 'Assignment Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text(_selectedFile?.name ?? 'Upload File'),
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

    if (_descriptionController.text.isEmpty && _selectedFile == null) {
      _showSnackBar('Please provide a description or upload a file');
      return;
    }

    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }

      final assignmentService = ref.read(assignmentServiceProvider.notifier);
      await assignmentService.createAssignment(
        token: authState.token!,
        classId: widget.classId,
        title: _assignmentNameController.text.trim(),
        deadline: DateFormat('yyyy-MM-ddTHH:mm:ss').format(_endDateTime!),
        description: _descriptionController.text,
        file: _selectedFile!,
      );

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
