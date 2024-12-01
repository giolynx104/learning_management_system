import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/providers/assignment_provider.dart';
import 'package:intl/intl.dart';

class SubmitAssignmentScreen extends ConsumerStatefulWidget {
  final Assignment assignment;

  const SubmitAssignmentScreen({
    super.key,
    required this.assignment,
  });

  @override
  ConsumerState<SubmitAssignmentScreen> createState() => _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends ConsumerState<SubmitAssignmentScreen> {
  late Assignment assignment;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _hasChanged = false;
  bool _isSubmitEnabled = false;
  Map<String, dynamic>? _submissionData;

  @override
  void initState() {
    super.initState();
    assignment = widget.assignment;
    _nameController.text = assignment.title;
    _descriptionController.addListener(_validateForm);
    _loadSubmission();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    bool isDescriptionFilled = _descriptionController.text.isNotEmpty;
    bool isFileUploaded = _selectedFile != null;

    setState(() {
      _isSubmitEnabled = (isDescriptionFilled || isFileUploaded) && _hasChanged;
    });
  }

  Future<void> _loadSubmission() async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }
      
      final submission = await ref.read(assignmentServiceProvider.notifier)
          .getStudentSubmission(
        token: authState.token!,
        assignmentId: assignment.id,
      );

      if (mounted) {
        setState(() {
          _submissionData = submission;
          if (_submissionData != null) {
            _descriptionController.text = _submissionData!['text_response'] ?? '';
          }
          _isSubmitEnabled = _submissionData == null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading submission: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isDeadlinePassed = assignment.deadline != null && 
        now.isAfter(assignment.deadline!);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Assignment'),
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
              // Assignment Info
              Text(
                assignment.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (assignment.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  assignment.description!,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 16),
              
              // Deadline Info
              if (assignment.deadline != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDeadlinePassed 
                        ? theme.colorScheme.errorContainer 
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: isDeadlinePassed 
                            ? theme.colorScheme.error 
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deadline: ${DateFormat('MMM dd, yyyy - HH:mm').format(assignment.deadline!)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDeadlinePassed 
                              ? theme.colorScheme.error 
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              if (_submissionData == null && !isDeadlinePassed) ...[
                // Submission Form
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Your Response',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  onChanged: (_) => setState(() => _hasChanged = true),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx'],
                    );

                    if (result != null) {
                      setState(() {
                        _selectedFile = result.files.single;
                        _hasChanged = true;
                      });
                      _validateForm();
                    }
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(_selectedFile?.name ?? 'Attach File'),
                ),
                if (_selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Selected file: ${_selectedFile!.name}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isSubmitEnabled
                      ? () async {
                          if (_selectedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select a file")),
                            );
                            return;
                          }

                          try {
                            final authState = await ref.read(authProvider.future);
                            if (authState == null) {
                              throw Exception('Not authenticated');
                            }

                            await ref.read(assignmentServiceProvider.notifier).submitAssignment(
                              token: authState.token!,
                              assignmentId: assignment.id,
                              file: _selectedFile!,
                            );

                            if (mounted) {
                              ref.invalidate(assignmentListProvider);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Assignment submitted successfully"),
                                ),
                              );
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: ${e.toString()}")),
                              );
                            }
                          }
                        }
                      : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Assignment'),
                ),
              ] else ...[
                // View Submission
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Submission',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_submissionData!['text_response']?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),
                        Text(
                          _submissionData!['text_response'],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (_submissionData!['file_url'] != null) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final url = _submissionData!['file_url'];
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Cannot open file")),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.attachment),
                          label: const Text('View Submitted File'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.grade,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Grade: ${_submissionData!['grade'] ?? 'Not graded yet'}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 