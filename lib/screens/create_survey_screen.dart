import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting DateTime
import 'package:learning_management_system/routes/app_routes.dart';
import 'package:file_picker/file_picker.dart';

class CreateSurveyScreen extends StatefulWidget {
  const CreateSurveyScreen({super.key});

  @override
  CreateSurveyScreenState createState() => CreateSurveyScreenState();
}

class CreateSurveyScreenState extends State<CreateSurveyScreen> {
  final FocusNode surveyNameFocusNode = FocusNode();

  // Controllers for TextFields
  final TextEditingController _surveyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // DateTime variables for "Bắt đầu" and "Kết thúc"
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _fileName; // Holds the name of the selected file

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to track changes in form inputs
    _surveyNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  // Method to validate the form based on conditions
  void _validateForm() {
    bool isDescriptionFilledOrFileUploaded = _descriptionController.text.isNotEmpty || _fileName != null;

    // If conditions are met, enable the submit button
    setState(() {
      _isSubmitEnabled = isDescriptionFilledOrFileUploaded;
    });
  }

  @override
  void dispose() {
    _surveyNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
              'CREATE SURVEY',
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
            Navigator.pushNamed(context, AppRoutes.signup); //change to actual route
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            TextField(
              controller: _surveyNameController,
              focusNode: surveyNameFocusNode,
              style: TextStyle(color: Colors.red[900]),
              decoration: InputDecoration(
                labelText: 'Tên bài kiểm tra',
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
            TextField(
              controller: _descriptionController,
              onChanged: (value) {
                _validateForm(); // Validate form whenever survey name changes
              },
              style: TextStyle(color: Colors.red[900]),
              decoration: InputDecoration(
                labelText: 'Mô tả',
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
              maxLines: 5,
              // Number of lines the field can expand to
              maxLength: 1000,
              // Maximum characters allowed
              keyboardType: TextInputType.multiline, // Allows multiline input
            ),
            const SizedBox(height: 0.0),
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
        ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await _selectDateTime(context, isStart: true);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Bắt đầu',
                        labelStyle: TextStyle(color: Colors.red[900]),
                        filled: true,
                        fillColor: Colors.white70,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.zero),
                          borderSide: BorderSide(color: Colors.red[900]!), // Explicitly set the border color to red
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.zero),
                          borderSide: BorderSide(color: Colors.red[900]!, width: 2.0), // Border when focused
                        ),
                        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.red[900]),
                      ),
                      child: Text(
                        _startDateTime == null
                            ? ''
                            : DateFormat('hh:mm a - dd-MM-yyyy').format(
                            _startDateTime!),
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await _selectDateTime(context, isStart: false);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Kết thúc',
                        labelStyle: TextStyle(color: Colors.red[900]),
                        filled: true,
                        fillColor: Colors.white70,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.zero),
                          borderSide: BorderSide(color: Colors.red[900]!), // Explicitly set the border color to red
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.zero),
                          borderSide: BorderSide(color: Colors.red[900]!, width: 2.0), // Border when focused
                        ),
                        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.red[900]),
                      ),
                      child: Text(
                        _endDateTime == null
                            ? ''
                            : DateFormat('hh:mm a - dd-MM-yyyy').format(
                            _endDateTime!),
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isSubmitEnabled
                  ? () {
                String surveyName = _surveyNameController.text.trim();

                // Check if survey name is empty
                if (surveyName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tên bài kiểm tra không được để trống")),
                  );
                  return;
                }

                // Check if start or end time is not entered
                if (_startDateTime == null || _endDateTime == null) {
                  String message = _startDateTime == null ? "Chưa chọn thời gian bắt đầu" : "Chưa chọn thời gian kết thúc";
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                  return;
                }

                // Check if start time is after end time
                if (_startDateTime!.isBefore(DateTime.now()) ||
                    _endDateTime!.isBefore(DateTime.now()) ||
                    _startDateTime!.isAfter(_endDateTime!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Thời gian bắt đầu/kết thúc không hợp lệ")),
                  );
                  return;
                }

                // If all validations pass
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tạo bài kiểm tra thành công")),
                );

                // Handle submit logic here

              }
                  : null, // Disable the button if the form is not valid
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _isSubmitEnabled ? Colors.red[900] : Colors.grey, // Change color based on enabled state
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                    fontSize: 16.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context,
      {required bool isStart}) async {
    // Show Date Picker
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && mounted) { // Check if the widget is still mounted
      // Show Time Picker
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null &&
          mounted) { // Check if the widget is still mounted
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStart) {
            _startDateTime = selectedDateTime;
          } else {
            _endDateTime = selectedDateTime;
          }
        });
      }
    }
  }
}