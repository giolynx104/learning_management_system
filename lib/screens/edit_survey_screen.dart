import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learning_management_system/models/survey.dart';
import 'package:learning_management_system/services/survey_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'dart:io';

class EditSurveyScreen extends ConsumerStatefulWidget {
  final String surveyId;
  final TeacherSurvey survey;

  const EditSurveyScreen({
    super.key,
    required this.surveyId,
    required this.survey,
  });

  @override
  EditSurveyScreenState createState() => EditSurveyScreenState();
}

class EditSurveyScreenState extends ConsumerState<EditSurveyScreen> {
  late TeacherSurvey survey;

  final TextEditingController _surveyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _endDateTime;
  String? _fileName;
  String? _fileUrl;

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    survey = widget.survey;
    _surveyNameController.text = survey.name;
    _descriptionController.text = survey.description ?? '';
    _fileName = survey.file; // Prefill file URL if exists
    _fileUrl = survey.file; // Assuming the survey has a file URL
    _endDateTime = survey.endTime; // Prefill end time

    _surveyNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      // Check if fields are modified
      final isNameNotEmpty = _surveyNameController.text.isNotEmpty;
      final isDescriptionOrFileNotEmpty = (_descriptionController.text.isNotEmpty || _fileName != null);

      // Check if the file has changed
      final isFileChanged = survey.file != _fileName;

      // Check for changes
      final isChanged = survey.name != _surveyNameController.text ||
          survey.description != _descriptionController.text ||
          isFileChanged ||
          survey.endTime != _endDateTime;

      _isSubmitEnabled = isChanged && isNameNotEmpty && isDescriptionOrFileNotEmpty && isFileChanged;
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Edit Assignment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _surveyNameController,
                  labelText: 'Tên bài kiểm tra *',
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _descriptionController,
                  labelText: 'Mô tả',
                  maxLines: 5,
                  maxLength: 1000,
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
                _buildFileActionButtons(),
                const SizedBox(height: 16.0),
                _buildEndDateSelector(),
                const SizedBox(height: 16.0),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    int? maxLines,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.red[900]),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.red[300]),
        filled: true,
        fillColor: Colors.white70,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: Colors.red),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: maxLines != null ? TextInputType.multiline : null,
    );
  }

  Widget _buildFileActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _fileUrl != null ? _openFileLink : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[900],
            foregroundColor: Colors.white,
          ),
          child: Text(
            _fileUrl != null ? 'Link đề bài' : 'Tải tài liệu lên ▲',
            style: const TextStyle(
              fontSize: 16.0,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_fileUrl != null)
          TextButton(
            onPressed: _pickNewFile,
            child: const Text(
              'Đổi file',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Future<void> _openFileLink() async {
    if (_fileUrl != null && await canLaunchUrl(Uri.parse(_fileUrl!))) {
      await launchUrl(Uri.parse(_fileUrl!));
    } else {
      _showSnackBar("Không thể mở đường dẫn tệp.");
    }
  }

  Future<void> _pickNewFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileUrl = result.files.single.path; // You can change this to the desired file URL logic
      });
      _validateForm();
    }
  }

  Widget _buildEndDateSelector() {
    return InkWell(
      onTap: () => _selectEndDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Kết thúc',
          labelStyle: TextStyle(color: Colors.red[900]),
          filled: true,
          fillColor: Colors.white70,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(color: Colors.red),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.red[900]),
        ),
        child: Text(
          _formatDateTime(_endDateTime),
          style: TextStyle(color: Colors.red[900]),
        ),
      ),
    );
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (context.mounted && pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (context.mounted && pickedTime != null) {
        setState(() {
          _endDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    return dateTime == null
        ? 'Chưa chọn'
        : DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  void _handleSubmit() async {
    if (_fileUrl == null || _fileName == null) {
      _showSnackBar('Please select a file.');
      return;
    }
    final authState = await ref.read(authProvider.future);
    if (authState == null) {
      throw Exception('Not authenticated');
    }
    final token = authState.token;  // Replace with the actual token from your auth provider
    final assignmentId = survey.id;  // Assuming survey.id is the ID you need to send
    final description = _descriptionController.text;
    final deadline = _endDateTime != null
        ? DateFormat("yyyy-MM-ddTHH:mm:ss").format(_endDateTime!)
        : '';

    // Create the file to upload
    if (_fileUrl != null) {
      try {
        final file = PlatformFile(
          path: _fileUrl!, // Ensure it's non-null by using '!'
          name: _fileName!,
          size: await File(_fileUrl!).length(),  // Calculate file size
        );
        final surveyService = ref.read(surveyServiceProvider.notifier);
        await surveyService.editSurvey(
          token: token!,
          assignmentId: assignmentId,
          deadline: deadline,
          description: description,
          file: file,
        );
        _showSnackBar('Assignment updated successfully!');
        Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context, true);
      } catch (e) {
        _showSnackBar('Error updating survey: ${e.toString()}');
      }
    } else {
      _showSnackBar('File path is null, cannot upload file.');
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitEnabled ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[900],
          foregroundColor: Colors.white,
        ),
        child: const Text(
          'Edit',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
