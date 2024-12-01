import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'dart:io';

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
  late Assignment assignment;
  final TextEditingController _assignmentNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _endDateTime;
  String? _fileName;
  String? _fileUrl;
  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    assignment = widget.assignment;
    _assignmentNameController.text = assignment.title;
    _descriptionController.text = assignment.description ?? '';
    _fileName = assignment.fileUrl;
    _fileUrl = assignment.fileUrl;
    _endDateTime = assignment.deadline;

    _assignmentNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      final isNameNotEmpty = _assignmentNameController.text.isNotEmpty;
      final isDescriptionOrFileNotEmpty = 
          (_descriptionController.text.isNotEmpty || _fileName != null);
      final isFileChanged = assignment.fileUrl != _fileName;
      final isChanged = assignment.title != _assignmentNameController.text ||
          assignment.description != _descriptionController.text ||
          isFileChanged ||
          assignment.deadline != _endDateTime;

      _isSubmitEnabled = isChanged && isNameNotEmpty && isDescriptionOrFileNotEmpty;
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
          title: const Text('Edit Assignment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
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
              _buildFileSection(),
              const SizedBox(height: 16),
              _buildDateTimeSelector(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitEnabled ? _handleSubmit : null,
                child: const Text('Update Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSection() {
    return Column(
      children: [
        if (_fileUrl != null)
          ElevatedButton(
            onPressed: _openFileLink,
            child: const Text('View Current File'),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _pickNewFile,
          child: Text(_fileName != null ? 'Change File' : 'Upload File'),
        ),
      ],
    );
  }

  Future<void> _openFileLink() async {
    if (_fileUrl != null && await canLaunchUrl(Uri.parse(_fileUrl!))) {
      await launchUrl(Uri.parse(_fileUrl!));
    } else {
      _showSnackBar("Cannot open file link");
    }
  }

  Future<void> _pickNewFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _fileName = result.files.first.name;
        _fileUrl = result.files.first.path;
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
      initialDate: _endDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDateTime ?? DateTime.now()),
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

  Future<void> _handleSubmit() async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) throw Exception('Not authenticated');

      final assignmentService = ref.read(assignmentServiceProvider.notifier);
      
      if (_fileUrl != null) {
        final file = PlatformFile(
          path: _fileUrl!,
          name: _fileName!,
          size: await File(_fileUrl!).length(),
        );

        await assignmentService.editAssignment(
          token: authState.token!,
          assignmentId: widget.assignmentId,
          title: _assignmentNameController.text,
          deadline: DateFormat('yyyy-MM-ddTHH:mm:ss').format(_endDateTime!),
          description: _descriptionController.text,
          file: file,
        );

        if (mounted) {
          _showSnackBar('Assignment updated successfully');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showSnackBar('Error updating assignment: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
} 