import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AbsenceRequestScreen extends StatefulWidget {
  const AbsenceRequestScreen({super.key});
  @override
  State<AbsenceRequestScreen> createState() => _AbsenceRequestScreenState();
}

class _AbsenceRequestScreenState extends State<AbsenceRequestScreen> {
  DateTime? _selectedDate;
  String? _selectedFile;
  final TextEditingController _reasonController = TextEditingController(); // Khai báo controller cho lý do

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
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedDate == null || _selectedFile == null) {
      // Kiểm tra nếu chưa chọn ngày hoặc file
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và upload file minh chứng')),
      );
      return;
    }

    final String reason = _reasonController.text; // Lấy lý do từ TextFormField
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // Sử dụng cú pháp của bạn để tạo URL
    var url = Uri.http('160.30.168.228:8080', '/it5023e/request_absence');

    // Gửi yêu cầu POST
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "token": "ZeLxSs", // temp
        "class_id": "783226", // temp
        'date': formattedDate,
        'reason': reason,
        // 'file': _selectedFile, // Bạn có thể gửi file nếu cần
        // "token": "vvNIaV",
        // "class_id": "783226",
        // "date": "2024-11-16",
        // "reason": "Ban di giai cuu the gioi"
      }),
    );

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu nghỉ phép đã được gửi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra. Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        toolbarHeight: 100.0,
        centerTitle: true,
        title: const Column(
          children: [
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Text('HUST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white)),
            ),
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Text('Nghỉ Phép', style: TextStyle(fontSize: 25, color: Colors.white)),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3.0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 30.0),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 150.0), // Giới hạn chiều cao tối đa
                child: TextFormField(
                  controller: _reasonController, // Sử dụng controller để lấy lý do
                  maxLines: null, // Cho phép xuống dòng không giới hạn số dòng
                  minLines: 3, // Số dòng tối thiểu
                  decoration: const InputDecoration(
                    labelText: 'Lý do',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 3.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0), // Điều chỉnh padding nội dung
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Chọn ngày',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 3.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 3.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                          : '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Upload minh chứng"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red[900]), // Đặt màu nền
                foregroundColor: WidgetStateProperty.all(Colors.white), // Đặt màu chữ
              ),
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text('File đã chọn: $_selectedFile'),
              ),
            const SizedBox(height: 20), // Thêm khoảng cách trước nút Submit
            ElevatedButton(
              onPressed: _submit, // Gọi hàm xử lý khi nhấn nút
              child: const Text("Submit"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red[900]), // Đặt màu nền
                foregroundColor: WidgetStateProperty.all(Colors.white), // Đặt màu chữ
              ),
            ),
          ],
        ),
      ),
    );
  }
}