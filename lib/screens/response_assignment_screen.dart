import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'dart:developer' as developer;

class ResponseAssignmentScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  const ResponseAssignmentScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  ResponseAssignmentScreenState createState() =>
      ResponseAssignmentScreenState();
}

class ResponseAssignmentScreenState
    extends ConsumerState<ResponseAssignmentScreen> {
  List<Map<String, dynamic>> responses = [];
  List<TextEditingController>? scoreControllers;

  @override
  void initState() {
    super.initState();
    _fetchAssignmentResponses();
    scoreControllers =
        List.generate(responses.length, (_) => TextEditingController());
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

      if (fetchedResponses.isNotEmpty) {
        developer.log(
          'Sample response structure: ${fetchedResponses.first}',
          name: 'ResponseAssignmentScreen',
        );
      }

      setState(() {
        responses = fetchedResponses;
        scoreControllers =
            List.generate(responses.length, (_) => TextEditingController());
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool isValidScore(String score) {
    final parsedScore = double.tryParse(score);
    return parsedScore != null && parsedScore >= 0 && parsedScore <= 10;
  }

  Future<void> _submitGrade(dynamic submissionId, String score) async {
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

      await _fetchAssignmentResponses(); // Refresh the list after grading
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

  Future<void> _openAttachment(String? fileUrl, String? fileName) async {
    if (fileUrl == null || fileUrl.isEmpty) {
      _showSnackBar('No file attached');
      return;
    }

    developer.log(
      'Attempting to open file: $fileUrl',
      name: 'ResponseAssignmentScreen',
    );

    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Cannot open file: URL is invalid');
      }
    } catch (e) {
      developer.log(
        'Error opening file',
        name: 'ResponseAssignmentScreen',
        error: e,
      );
      _showSnackBar('Error opening file: ${e.toString()}');
    }
  }

  Widget _buildResponseCard(
    BuildContext context,
    Map<String, dynamic> response,
    int index,
    ThemeData theme,
  ) {
    final student = response['student_account'];
    final score = response['grade'];
    final submissionId = response['id'];

    developer.log(
      'Response data for card $index: ${response.toString()}',
      name: 'ResponseAssignmentScreen',
    );

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
                    '${student['first_name'][0]}${student['last_name'][0]}',
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
                        '${student['first_name']} ${student['last_name']}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student['email'] ?? '',
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
                          .format(DateTime.parse(response['submission_time'])),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Response Text
                if (response['text_response']?.isNotEmpty ?? false) ...[
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
                      response['text_response'] ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(height: 32),

                // Grading Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (score != null) ...[
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
                                '$score/10',
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
                              labelText: score != null ? 'Update Grade (0-10)' : 'Grade (0-10)',
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
                        await _submitGrade(submissionId, scoreText);
                        scoreControllers?[index].clear();
                      },
                      icon: const Icon(Icons.check),
                      label: Text(score != null ? 'Update' : 'Grade'),
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
