import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/services/survey_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class CreateSurveyScreen extends ConsumerStatefulWidget {
  final String classId;
  const CreateSurveyScreen({super.key, required this.classId});

  @override
  CreateSurveyScreenState createState() => CreateSurveyScreenState();
}

class CreateSurveyScreenState extends ConsumerState<CreateSurveyScreen> {
  final TextEditingController _surveyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _endDateTime;
  String? _fileName;
  PlatformFile? _selectedFile;
  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    _surveyNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isSubmitEnabled = _surveyNameController.text.isNotEmpty &&
          (_descriptionController.text.isNotEmpty || _fileName != null);
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
          toolbarHeight: 100,
          backgroundColor: Colors.red[900],
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/HUST_white.png',
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.white);
                },
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
                _buildFilePickerButton(),
                const SizedBox(height: 16.0),
                _buildDateTimeSelector(),
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

  Widget _buildFilePickerButton() {
    return ElevatedButton(
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['docx', 'png', 'pdf'],
        );

        if (result != null) {
          setState(() {
            _selectedFile = result.files.single;
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
    );
  }

  Widget _buildDateTimeSelector() {
    return InkWell(
      onTap: () => _selectDateTime(context),
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitEnabled ? _handleSubmit : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isSubmitEnabled ? Colors.red[900] : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: const Text(
        'Create',
        style: TextStyle(
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Future<void> _selectDateTime(BuildContext context) async {
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
        ? ''
        : DateFormat('hh:mm a - dd-MM-yyyy').format(dateTime);
  }

  Future<void> _handleSubmit() async {
    print("Submit button clicked!"); // Debugging log

    final surveyName = _surveyNameController.text.trim();
    if (surveyName.isEmpty) {
      _showSnackBar("Tên bài kiểm tra không được để trống");
      print("Survey name is empty."); // Debugging log
      return;
    }

    if (_descriptionController.text.isEmpty && _selectedFile == null) {
      _showSnackBar("Vui lòng nhập mô tả hoặc tải tài liệu lên");
      print("Description and file are empty."); // Debugging log
      return;
    }

    if (_endDateTime == null) {
      _showSnackBar("Chưa chọn thời gian kết thúc");
      print("End date/time not selected."); // Debugging log
      return;
    }

    final authState = await ref.read(authProvider.future);
    if (authState == null) {
      print("Not authenticated.");
      throw Exception('Not authenticated');
    }
    final formattedDeadline = DateFormat("yyyy-MM-ddTHH:mm:ss").format(_endDateTime!);

    try {
      final surveyService = ref.read(surveyServiceProvider.notifier);
      await surveyService.createSurvey(
        token: authState.token,
        classId: widget.classId,
        title: surveyName,
        deadline: formattedDeadline,
        description: _descriptionController.text,
        file: _selectedFile!,
      );
      _showSnackBar("Tạo bài kiểm tra thành công!");
      Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Lỗi khi tạo bài kiểm tra: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
