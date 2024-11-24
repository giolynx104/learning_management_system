import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/services/survey_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'dart:io';

class ResponseSurveyScreen extends ConsumerStatefulWidget {
  final String surveyId;
  const ResponseSurveyScreen({
    super.key,
    required this.surveyId,
  });

  @override
  ResponseSurveyScreenState createState() => ResponseSurveyScreenState();
}

class ResponseSurveyScreenState extends ConsumerState<ResponseSurveyScreen> {
  List<Map<String, dynamic>> responses = []; // Holds the fetched response data
  List<TextEditingController>? scoreControllers; // Holds the controllers for scores

  @override
  void initState() {
    super.initState();
    // Initialize controllers once the state is created
    _fetchSurveyResponses(); // Fetch survey responses on init
    scoreControllers = List.generate(responses.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    // Dispose controllers when no longer needed
    for (var controller in scoreControllers ?? []) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchSurveyResponses() async {
    final authState = await ref.read(authProvider.future);
    if (authState == null) {
      throw Exception('Not authenticated');
    }
    final surveyService = ref.read(surveyServiceProvider.notifier);

    try {
      final fetchedResponses = await surveyService.responseSurvey(
        token: authState.token!,
        surveyId: widget.surveyId,
      );

      setState(() {
        responses = fetchedResponses; // Now it's a list of responses
        // Initialize scoreControllers after the responses are fetched
        scoreControllers = List.generate(responses.length, (_) => TextEditingController());
      });
    } catch (e) {
      print('Error fetching survey responses: $e');
    }
  }



  // Function to display snack bar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Function to validate score input
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
            // Text on top of the list
            Text(
              'Tổng số phản hồi: ${responses.length}',
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
                                      'Điểm: ${score != null ? score.toString() : "Chưa có"}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Phản hồi: ${response['text_response'] ?? ''}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thời gian nộp: ${DateFormat('hh:mm a - dd-MM-yyyy').format(DateTime.parse(response['submission_time']))}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              // Open file URL (if present)
                              final url = response['file_url'];
                              if (url != null && await canLaunch(url)) {
                                await launch(url);
                              } else {
                                _showSnackBar('Không thể mở file.');
                              }
                            },
                            child: const Text(
                              'Xem File',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: scoreControllers?[index], // Use the controller for the specific index
                            decoration: InputDecoration(
                              labelText: 'Nhập điểm',
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

                              // Check if the input is empty
                              if (scoreText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Vui lòng nhập điểm.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else if (!isValidScore(scoreText)) {
                                // Check if the score is valid
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Điểm không hợp lệ.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                // If score is valid, proceed to submit

                                final authState = await ref.read(authProvider.future);
                                if (authState == null) {
                                  throw Exception('Not authenticated');
                                }
                                final surveyService = ref.read(surveyServiceProvider.notifier);

                                final response = responses[index];
                                final submissionId = response['id'];

                                final gradeData = {
                                  "score": scoreText,
                                  "submission_id": submissionId.toString(),
                                };

                                try {
                                  // Call the responseSurvey function with the grade data
                                  await surveyService.responseSurvey(
                                    token: authState.token!,
                                    surveyId: widget.surveyId,
                                    score: scoreText,
                                    submissionId: submissionId.toString(),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Điểm đã được chấm thành công: {$scoreText}'),
                                    ),
                                  );
                                  _fetchSurveyResponses();
                                } catch (e) {
                                  print('Error submitting grade: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã có lỗi khi chấm điểm.'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'Xác nhận',
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
