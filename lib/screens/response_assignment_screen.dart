import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/services/assignment_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

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
  List<Map<String, dynamic>> responses = [];
  List<TextEditingController>? scoreControllers;

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

      setState(() {
        responses = fetchedResponses;
        scoreControllers = List.generate(
          responses.length, 
          (_) => TextEditingController()
        );
      });
    } catch (e) {
      print('Error fetching assignment responses: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool isValidScore(String score) {
    final parsedScore = double.tryParse(score);
    return parsedScore != null && parsedScore >= 0 && parsedScore <= 10;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Responses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total Responses: ${responses.length}',
              style: TextStyle(
                color: Colors.red[900],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: responses.length,
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  final response = responses[index];
                  final student = response['student_account'];
                  final score = response['grade'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
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
                                    const SizedBox(height: 8),
                                    Text(
                                      student['email'] ?? '',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Score: ${score != null ? score.toString() : "Not graded"}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Response: ${response['text_response'] ?? ''}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Submitted: ${DateFormat('hh:mm a - dd-MM-yyyy').format(DateTime.parse(response['submission_time']))}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final url = response['file_url'];
                              if (url != null && await canLaunch(url)) {
                                await launch(url);
                              } else {
                                _showSnackBar('Cannot open file.');
                              }
                            },
                            child: const Text(
                              'View File',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: scoreControllers?[index],
                            decoration: const InputDecoration(
                              labelText: 'Enter Score',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              String scoreText = scoreControllers?[index].text ?? "";
                              if (scoreText.isEmpty) {
                                _showSnackBar('Please enter a score.');
                                return;
                              }

                              try {
                                final authState = await ref.read(authProvider.future);
                                if (authState == null) throw Exception('Not authenticated');

                                final assignmentService = ref.read(assignmentServiceProvider.notifier);
                                final submissionId = response['id'].toString();

                                await assignmentService.gradeAssignment(
                                  token: authState.token!,
                                  assignmentId: widget.assignmentId,
                                  score: scoreText,
                                  submissionId: submissionId,
                                );

                                _showSnackBar('Score submitted successfully: $scoreText');
                                _fetchAssignmentResponses();
                              } catch (e) {
                                _showSnackBar('Error submitting score: $e');
                              }
                            },
                            child: const Text(
                              'Submit Score',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 