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
  // File upload constants
  static const int MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
  static const List<String> ALLOWED_EXTENSIONS = [
    'pdf', 'doc', 'docx', 'txt', 'rtf',
    'png', 'jpg', 'jpeg',
    'xlsx', 'xls',
    'zip', 'rar'
  ];

  // File validation helpers
  String? _getFileError(PlatformFile file) {
    // Check file size
    if (file.size > MAX_FILE_SIZE) {
      return 'File size must be less than 10MB';
    }

    // Check file extension
    final extension = file.extension?.toLowerCase();
    if (extension == null || !ALLOWED_EXTENSIONS.contains(extension)) {
      return 'Invalid file type. Allowed types: ${ALLOWED_EXTENSIONS.join(", ")}';
    }

    // Check file name length
    if (file.name.length > 255) {
      return 'File name is too long';
    }

    // Check for malicious file names
    if (file.name.contains('..') || 
        file.name.contains('/') || 
        file.name.contains('\\')) {
      return 'Invalid file name';
    }

    return null;
  }

  String _sanitizeFileName(String fileName) {
    // Remove special characters and spaces
    final sanitized = fileName
        .replaceAll(RegExp(r'[^\w\s\-\.]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    
    // Ensure the filename isn't too long
    const maxLength = 100;
    if (sanitized.length > maxLength) {
      final extension = sanitized.split('.').last;
      return '${sanitized.substring(0, maxLength - extension.length - 1)}.$extension';
    }
    
    return sanitized;
  }

  final TextEditingController _assignmentNameController =
      TextEditingController();
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attachment (Optional)',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Allowed file types: ${ALLOWED_EXTENSIONS.join(", ")}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          'Maximum file size: ${(MAX_FILE_SIZE / (1024 * 1024)).toStringAsFixed(0)}MB',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _pickFile,
                                icon: const Icon(Icons.attach_file),
                                label: Text(_selectedFile?.name ?? 'Choose File'),
                                style: ElevatedButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                            if (_selectedFile != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _isLoading
                                    ? null
                                    : () => setState(() {
                                          _selectedFile = null;
                                          _validateForm();
                                        }),
                                tooltip: 'Remove file',
                              ),
                            ],
                          ],
                        ),
                        if (_selectedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Size: ${(_selectedFile!.size / 1024).toStringAsFixed(1)}KB',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
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

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ALLOWED_EXTENSIONS,
        withData: true,
        onFileLoading: (FilePickerStatus status) => debugPrint(status.toString()),
      );

      if (result != null) {
        final file = result.files.first;
        
        // Validate file
        final error = _getFileError(file);
        if (error != null) {
          if (mounted) {
            _showSnackBar(error);
          }
          return;
        }

        // Sanitize file name
        final sanitizedName = _sanitizeFileName(file.name);
        debugPrint('Original filename: ${file.name}');
        debugPrint('Sanitized filename: $sanitizedName');
        
        setState(() {
          _selectedFile = file;
        });
        _validateForm();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error picking file: ${e.toString()}');
      }
    }
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
