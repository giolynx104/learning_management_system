import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/services/survey_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubmitSurveyScreen extends ConsumerStatefulWidget {
  // Required parameter for Survey
  final Survey survey;

  const SubmitSurveyScreen({
    super.key,
    required this.survey, // Make survey a required parameter
  });

  @override
  ConsumerState<SubmitSurveyScreen> createState() => _SubmitSurveyScreenState();
}

class _SubmitSurveyScreenState extends ConsumerState<SubmitSurveyScreen> {
  late Survey survey;

  // Controllers for TextFields
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surveyDescriptionController = TextEditingController();
  final TextEditingController _answerDescriptionController = TextEditingController();

  String? _fileName; // Holds the name of the selected file
  PlatformFile? _selectedFile; // File selected by user
  String? _token; // Token for API call (fetch from provider or pass it as required)

  bool _hasChanged = false; // Tracks if user has changed the input or file

  bool _isSubmitEnabled = false;
  Map<String, dynamic>? _submissionData;
  @override
  void initState() {
    super.initState();
    survey = widget.survey;
    _nameController.text = survey.title;
    _surveyDescriptionController.text = survey.description ?? '';
    _answerDescriptionController.text = ''; // Initially empty

    _descriptionController.addListener(_validateForm);
    _loadSubmission();
  }
  Future<void> _loadSubmission() async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }
      final surveyService = ref.read(surveyServiceProvider.notifier);
      final submission = await surveyService.getSubmission(
        token: authState.token!,
        assignmentId: survey.id,
      );

      setState(() {
        _submissionData = submission;
        if (_submissionData != null) {
          _answerDescriptionController.text = _submissionData!['text_response'];
          _descriptionController.text = _submissionData!['text_response'];
        }
        _isSubmitEnabled = _submissionData == null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading submission: ${e.toString()}")),
      );
    }
  }
  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    _surveyDescriptionController.dispose();
    _answerDescriptionController.dispose();
    super.dispose();
  }

  // Method to validate the form based on conditions
  void _validateForm() {
    bool isDescriptionFilled = _descriptionController.text.isNotEmpty;
    bool isFileUploaded = _selectedFile != null;

    setState(() {
      _isSubmitEnabled = (isDescriptionFilled && isFileUploaded) && _hasChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Submit Assignment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Change to actual route
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              TextField(
                controller: _nameController, // Use controller instead of hintText
                readOnly: true,
                style: TextStyle(color: Colors.red[900]),
                decoration: InputDecoration(
                  labelText: 'Tên bài kiểm tra', // Label will always stay at top left
                  labelStyle: TextStyle(color: Colors.red[300]),
                  filled: true,
                  fillColor: Colors.white70,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              if (survey.description != null) ...[
                TextField(
                  controller: _surveyDescriptionController, // Use controller instead of hintText
                  readOnly: true,
                  style: TextStyle(color: Colors.red[900]),
                  decoration: InputDecoration(
                    labelText: 'Mô tả', // Label will stay at top left
                    labelStyle: TextStyle(color: Colors.red[300]),
                    filled: true,
                    fillColor: Colors.white70,
                    alignLabelWithHint: true,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16.0),
              ],
              if (survey.file != null) ...[
                ElevatedButton(
                  onPressed: survey.file != null
                      ? () async {
                    final Uri url = Uri.parse(survey.file!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cannot open the URL")),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    (survey.file != null) ? 'Link file đề bài' : ' ',
                    style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
              const SizedBox(height: 20.0),

              if (_submissionData == null) ...[
                TextField(
                  controller: _descriptionController,
                  onChanged: (value) {
                    _validateForm();
                  },
                  style: TextStyle(color: Colors.red[900]),
                  decoration: InputDecoration(
                    labelText: 'Mô tả nộp bài',
                    labelStyle: TextStyle(color: Colors.red[300]),
                    filled: true,
                    fillColor: Colors.white70,
                    alignLabelWithHint: true,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Hoặc',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['docx', 'png', 'pdf'],
                    );

                    if (result != null) {
                      setState(() {
                        _selectedFile = result.files.single;
                        _hasChanged = true; // Mark as changed when a new file is selected
                      });
                      _validateForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _selectedFile?.name ?? 'Tải tài liệu lên    ▲',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                if (survey.deadline.isAfter(DateTime.now())) ...[
                  ElevatedButton(
                    onPressed: _isSubmitEnabled
                        ? () async {
                      try {
                        final authState = await ref.read(authProvider.future);
                        if (authState == null) {
                          throw Exception('Not authenticated');
                        }
                        final surveyService = ref.read(surveyServiceProvider.notifier);
                        await surveyService.submitSurvey(
                          token: authState.token!,
                          assignmentId: survey.id,
                          file: _selectedFile!,
                          textResponse: _descriptionController.text,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Submit Assignment Successfully"),
                          ),
                        );

                        setState(() {
                          _hasChanged = false; // Reset change tracking after submission
                          _isSubmitEnabled = false;
                        });
                        Future.delayed(Duration(milliseconds: 500));
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitEnabled ? Colors.red[900] : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              ]else...[
                TextField(
                  controller: _answerDescriptionController,
                  readOnly: true,
                  style: TextStyle(color: Colors.red[900]),
                  decoration: InputDecoration(
                    labelText: 'Mô tả nộp bài',
                    labelStyle: TextStyle(color: Colors.red[300]),
                    filled: true,
                    fillColor: Colors.white70,
                    alignLabelWithHint: true,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final Uri url = Uri.parse(_submissionData!['file_url']);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cannot open the URL")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Link file bài nộp',
                    style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Điểm: ${_submissionData!['grade'] ?? 'chưa có'}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
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
