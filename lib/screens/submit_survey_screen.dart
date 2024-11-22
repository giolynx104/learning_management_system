import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
import 'package:file_picker/file_picker.dart';

class SubmitSurveyScreen extends ConsumerStatefulWidget {
  // Required parameter for Survey
  final SmallSurvey survey;

  const SubmitSurveyScreen({
    super.key,
    required this.survey, // Make survey a required parameter
  });

  @override
  ConsumerState<SubmitSurveyScreen> createState() => _SubmitSurveyScreenState();
}

class SmallSurvey {
  final String name;
  final String? description;
  final String? file; // Path or URL to the survey file
  final String? answerDescription;
  final String? answerFile; // Path or URL to the answer file
  DateTime endTime;

  SmallSurvey({
    required this.name,
    this.description,
    this.file,
    this.answerDescription,
    this.answerFile,
    required this.endTime,
  });
}

class _SubmitSurveyScreenState extends ConsumerState<SubmitSurveyScreen> {
  late SmallSurvey survey;

  // Controllers for TextFields
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surveyDescriptionController = TextEditingController();
  final TextEditingController _answerDescriptionController = TextEditingController();

  String? _fileName; // Holds the name of the selected file

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appBarNotifierProvider.notifier).setAppBar(
        title: 'Submit Survey',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show survey help
            },
          ),
        ],
      );
    });
    // Directly use the passed survey
    survey = widget.survey;

    // Set the initial value for the read-only fields
    _nameController.text = survey.name;
    if (survey.description != null) {
      _surveyDescriptionController.text = survey.description!;
    }
    if (survey.answerDescription != null) {
      _answerDescriptionController.text = survey.answerDescription!;
    }

    _descriptionController.addListener(_validateForm);
  }

  @override
  void dispose() {
    ref.read(appBarNotifierProvider.notifier).reset();
    _descriptionController.dispose();
    _nameController.dispose();
    _surveyDescriptionController.dispose();
    _answerDescriptionController.dispose();
    super.dispose();
  }

  // Method to validate the form based on conditions
  void _validateForm() {
    bool isDescriptionFilledOrFileUploaded = _descriptionController.text
        .isNotEmpty || _fileName != null;

    // If conditions are met, enable the submit button
    setState(() {
      _isSubmitEnabled = isDescriptionFilledOrFileUploaded;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.red[900],
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min, // Use min size to fit the content
          children: [
            Image.asset(
              'assets/images/HUST_white.png', // Replace with your image path
              height: 40, // Set the height as needed
              fit: BoxFit.contain, // Adjust the fit as needed
            ),
            const SizedBox(height: 5.0),
            const Text(
              'SUBMIT SURVEY',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Times New Roman',
              ),
            ),
          ],
        ),
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
              if (survey.file != null)...[
                ElevatedButton(
                  onPressed: () {
                    // Handle file logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    survey.file ?? ' ',
                    style: const TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
              const SizedBox(height: 20.0),

              survey.answerDescription == null
                  ? TextField(
                controller: _descriptionController,
                onChanged: (value) {
                  _validateForm(); // Validate form whenever survey name changes
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
              )
                  : TextField(
                readOnly: true,
                style: TextStyle(color: Colors.red[900]),
                decoration: InputDecoration(
                  hintText: survey.answerDescription,
                  hintStyle: TextStyle(color: Colors.red[900]),
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
              survey.answerFile == null
                  ? ElevatedButton(
                  onPressed: () async {
                    // Open file picker to select a .docx file
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['docx'], // Only allow .docx files
                    );

                    if (result != null) {
                      // Get the file name
                      String fileName = result.files.single.name;

                      // Update the button text with the selected file name
                      setState(() {
                        _fileName = fileName;
                      });
                      _validateForm();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _fileName != null
                        ? _fileName! // Display the file name after selection
                        : 'Tải tài liệu lên    ▲', // Default button text
                    style: const TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                    ),
                  )
                  :ElevatedButton(
                    onPressed: () {
                      // Handle file logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      survey.answerFile ?? ' ',
                      style: const TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 16.0),
              // Inside the build method:
              survey.endTime.isAfter(DateTime.now())
                  ? ElevatedButton(
                onPressed: _isSubmitEnabled
                    ? () {
                  // Handle submit logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nộp bài kiểm tra thành công")),
                  );
                }
                    : null, // Disable the button if the form is not valid
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitEnabled ? Colors.red[900] : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Submit',  // Display "Submit" if the deadline has not passed
                  style: TextStyle(
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
              )
                  : ElevatedButton(
                onPressed: _isSubmitEnabled
                    ? () {
                  // Handle submit logic for late turn-in here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Turned in late")),
                  );
                }
                    : null, // Disable the button if the form is not valid
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitEnabled ? Colors.red[900] : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Turn in late', // Display "Turn in late" if the deadline has passed
                  style: TextStyle(
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
