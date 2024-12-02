import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/models/assignment_submission.dart';
import 'package:learning_management_system/utils/url_utils.dart';
import 'dart:developer' as developer;

class ResponseAssignmentScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  const ResponseAssignmentScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  ResponseAssignmentScreenState createState() => ResponseAssignmentScreenState();
}

class ResponseAssignmentScreenState extends ConsumerState<ResponseAssignmentScreen> {
  List<AssignmentSubmission> responses = [];
  List<TextEditingController>? scoreControllers;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool isValidScore(String score) {
    final parsedScore = double.tryParse(score);
    return parsedScore != null && parsedScore >= 0 && parsedScore <= 10;
  }

  Future<void> _openAttachment(String? fileUrl) async {
    debugPrint('Attempting to open material link: $fileUrl');
    if (fileUrl == null || fileUrl.isEmpty) {
      debugPrint('Material link is null or empty');
      _showSnackBar('No file link available');
      return;
    }

    // Parse the URL and ensure it's encoded properly
    var uri = Uri.parse(fileUrl);
    
    // Special handling for Google Drive/Docs URLs
    if (uri.host.contains('google.com')) {
      debugPrint('Detected Google Docs/Drive URL');
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        debugPrint('URL launch result: $launched');
        
        if (!launched) {
          // If external app launch fails, try browser
          final browserLaunched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          debugPrint('Browser launch result: $browserLaunched');
          
          if (!browserLaunched && mounted) {
            _showSnackBar('Could not open file. Please check if you have a compatible app installed.');
          }
        }
      } catch (e) {
        debugPrint('Error launching Google URL: $e');
        // Try fallback to browser if app launch fails
        try {
          final browserLaunched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          debugPrint('Fallback browser launch result: $browserLaunched');
          
          if (!browserLaunched && mounted) {
            _showSnackBar('Could not open file. Please check if you have a compatible app installed.');
          }
        } catch (e) {
          debugPrint('Error launching in browser: $e');
          if (mounted) {
            _showSnackBar('Error opening file: $e');
          }
        }
      }
    } else {
      // For non-Google URLs, use the standard approach
      try {
        final canLaunch = await canLaunchUrl(uri);
        debugPrint('Can launch URL: $canLaunch');
        if (canLaunch) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          debugPrint('URL launch result: $launched');
        } else {
          debugPrint('Cannot launch URL');
          if (mounted) {
            _showSnackBar('Could not open file');
          }
        }
      } catch (e) {
        debugPrint('Error launching URL: $e');
        if (mounted) {
          _showSnackBar('Error opening file: $e');
        }
      }
    }
  }

  String _getFileNameFromUrl(String url) {
    // For Google Drive URLs, extract the document name
    if (url.contains('docs.google.com')) {
      final docId = url.split('/')[5];
      return 'Google Doc: ${docId.substring(0, 8)}...';
    }
    return 'View Attachment';
  }

  @override
  void initState() {
    super.initState();
    _fetchAssignmentResponses();
    scoreControllers = List.generate(responses.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in scoreControllers ?? []) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAssignmentResponses() async {
    developer.log(
      'Fetching responses for assignment: ${widget.assignmentId}',
      name: 'ResponseAssignmentScreen',
    );

    final authState = await ref.read(authProvider.future);
    if (authState == null) {
      throw Exception('Not authenticated');
    }
    final assignmentService = ref.read(assignmentServiceProvider.notifier);

    try {
      final fetchedResponses = await assignmentService.getAssignmentResponses(
        token: authState.token!,
        assignmentId: widget.assignmentId,
      );

      developer.log(
        'Fetched ${fetchedResponses.length} responses',
        name: 'ResponseAssignmentScreen',
      );

      setState(() {
        responses = fetchedResponses;
        scoreControllers = List.generate(
          responses.length,
          (_) => TextEditingController(),
        );
      });
    } catch (e) {
      developer.log(
        'Error fetching assignment responses',
        name: 'ResponseAssignmentScreen',
        error: e,
      );
      _showSnackBar('Failed to load responses: ${e.toString()}');
    }
  }

  Future<void> _submitGrade(int submissionId, String score) async {
    try {
      developer.log(
        'Submitting grade for submission: $submissionId, score: $score',
        name: 'ResponseAssignmentScreen',
      );

      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }

      final assignmentService = ref.read(assignmentServiceProvider.notifier);
      await assignmentService.gradeAssignment(
        token: authState.token!,
        assignmentId: widget.assignmentId,
        submissionId: submissionId.toString(),
        score: score,
      );

      await _fetchAssignmentResponses();
      _showSnackBar('Grade submitted successfully');
    } catch (e) {
      developer.log(
        'Error submitting grade',
        name: 'ResponseAssignmentScreen',
        error: e,
      );
      _showSnackBar('Failed to submit grade: ${e.toString()}');
    }
  }

  Widget _buildResponseCard(
    BuildContext context,
    AssignmentSubmission submission,
    int index,
    ThemeData theme,
  ) {
    final hasFile = submission.fileUrl != null && submission.fileUrl!.isNotEmpty;
    final hasTextResponse = submission.textResponse != null && submission.textResponse!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Info Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '${submission.studentAccount.firstName[0]}${submission.studentAccount.lastName[0]}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${submission.studentAccount.firstName} ${submission.studentAccount.lastName}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        submission.studentAccount.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Response Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Submission Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(submission.submissionTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Response Type Indicator
                Row(
                  children: [
                    Icon(
                      hasFile ? Icons.attachment : Icons.text_fields,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasFile ? 'File Submission' : 'Text Submission',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Text Response
                if (hasTextResponse) ...[
                  Text(
                    'Response',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      submission.textResponse!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // File Attachment
                if (hasFile)
                  OutlinedButton.icon(
                    onPressed: () => openFileUrl(context, submission.fileUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(getFileNameFromUrl(submission.fileUrl!)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                if (hasFile || hasTextResponse)
                  const Divider(height: 32),

                // Grading Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (submission.grade != null) ...[
                            Text(
                              'Current Grade',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${submission.grade}/10',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextField(
                            controller: scoreControllers?[index],
                            decoration: InputDecoration(
                              labelText: submission.grade != null ? 'Update Grade (0-10)' : 'Grade (0-10)',
                              border: const OutlineInputBorder(),
                              hintText: '0-10',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        String scoreText = scoreControllers?[index].text ?? "";
                        if (!isValidScore(scoreText)) {
                          _showSnackBar('Please enter a valid score (0-10).');
                          return;
                        }
                        await _submitGrade(submission.id, scoreText);
                        scoreControllers?[index].clear();
                      },
                      icon: const Icon(Icons.check),
                      label: Text(submission.grade != null ? 'Update' : 'Grade'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Responses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Responses: ${responses.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: responses.length,
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) => _buildResponseCard(
                  context,
                  responses[index],
                  index,
                  theme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
