import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class AbsenceRequestScreen extends StatefulWidget {
  const AbsenceRequestScreen({super.key});

  @override
  State<AbsenceRequestScreen> createState() => _AbsenceRequestScreenState();
}

class _AbsenceRequestScreenState extends State<AbsenceRequestScreen> {
  DateTime? _selectedDate;
  File? _selectedFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a date and upload proof file')),
      );
      return;
    }

    final String title = _titleController.text;
    final String reason = _reasonController.text;
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      var uri = Uri.parse('http://157.66.24.126:8080/it5023e/request_absence');
      var request = http.MultipartRequest('POST', uri);

      // Thêm các trường form data
      request.fields['token'] = 'Wyg76E';
      request.fields['classId'] = '000002';
      request.fields['date'] = formattedDate;
      request.fields['reason'] = reason;
      request.fields['title'] = title;

      // Thêm file
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedFile!.path),
      );

      // Gửi request
      var response = await request.send();

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Absence request submitted successfully')),
        );
      } else {
        throw Exception('Failed to submit request');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absence Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : '',
                      ),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickDate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Upload Proof'),
                    ),
                    if (_selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Selected file: ${_selectedFile!.path.split('/').last}'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submit,
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
