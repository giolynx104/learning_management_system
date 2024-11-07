import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class EditSurveyScreen extends StatefulWidget {
  final TeacherSmallSurvey survey;

  const EditSurveyScreen({
    super.key,
    required this.survey, // Make survey a required parameter
  });

  @override
  EditSurveyScreenState createState() => EditSurveyScreenState();
}

class TeacherSmallSurvey {
  final String name;
  final String? description;
  final String? file;
  DateTime startTime;
  DateTime endTime;

  TeacherSmallSurvey({
    required this.name,
    this.description,
    this.file,
    required this.startTime,
    required this.endTime,
  });
}

class EditSurveyScreenState extends State<EditSurveyScreen> {
  late TeacherSmallSurvey survey;

  final TextEditingController _surveyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _fileName;

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    survey = widget.survey;
    _surveyNameController.text = survey.name;
    _descriptionController.text = survey.description ?? '';
    _fileName = survey.file; // Prefill file name if exists
    _startDateTime = survey.startTime; // Prefill start time
    _endDateTime = survey.endTime; // Prefill end time

    _surveyNameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      // Check if fields are modified
      final isNameNotEmpty = _surveyNameController.text.isNotEmpty;
      final isDescriptionOrFileNotEmpty = (_descriptionController.text.isNotEmpty || _fileName != null);

      // Check for changes
      final isChanged = survey.name != _surveyNameController.text ||
          survey.description != _descriptionController.text ||
          survey.file != _fileName ||
          survey.startTime != _startDateTime ||
          survey.endTime != _endDateTime;

      _isSubmitEnabled = isChanged && isNameNotEmpty && isDescriptionOrFileNotEmpty;
    });
  }

// The rest of your existing code remains unchanged.


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
                'EDIT SURVEY',
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
                _buildDateTimeSelectors(),
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
      onPressed: _pickFile,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      child: Text(
        _fileName ?? 'Tải tài liệu lên ▲',
        style: const TextStyle(
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    return Row(
      children: [
        Expanded(child: _buildDateTimeSelector(isStart: true)),
        const SizedBox(width: 16.0),
        Expanded(child: _buildDateTimeSelector(isStart: false)),
      ],
    );
  }

  Widget _buildDateTimeSelector({required bool isStart}) {
    return InkWell(
      onTap: () => _selectDateTime(context, isStart: isStart),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isStart ? 'Bắt đầu' : 'Kết thúc',
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
          _formatDateTime(isStart ? _startDateTime : _endDateTime),
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
        'Submit',
        style: TextStyle(
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
      _validateForm();
    }
  }

  Future<void> _selectDateTime(BuildContext context,
      {required bool isStart}) async {
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
          final selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startDateTime = selectedDateTime;
          } else {
            _endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    return dateTime == null
        ? ''
        : DateFormat('hh:mm a - dd-MM-yyyy').format(dateTime);
  }

  void _handleSubmit() {
    final surveyName = _surveyNameController.text.trim();

    if (surveyName.isEmpty) {
      _showSnackBar("Tên bài kiểm tra không được để trống");
      return;
    }

    if (_descriptionController.text.isEmpty && _fileName == null) {
      _showSnackBar("Vui lòng nhập mô tả hoặc tải tài liệu lên");
      return;
    }

    if (_startDateTime == null || _endDateTime == null) {
      _showSnackBar(_startDateTime == null
          ? "Chưa chọn thời gian bắt đầu"
          : "Chưa chọn thời gian kết thúc");
      return;
    }

    if (_startDateTime!.isBefore(DateTime.now()) ||
        _endDateTime!.isBefore(DateTime.now()) ||
        _startDateTime!.isAfter(_endDateTime!)) {
      _showSnackBar("Thời gian bắt đầu/kết thúc không hợp lệ");
      return;
    }

    _showSnackBar("Tạo bài kiểm tra thành công");
    // Handle submit logic here
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
