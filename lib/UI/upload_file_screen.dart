import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  _UploadFileScreenState createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  List<Map<String, dynamic>> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    // Thêm một vài file demo vào danh sách khi ứng dụng khởi động
    selectedFiles = [
      {'name': 'Document1.pdf', 'size': 1024},
      {'name': 'Image2.jpg', 'size': 2048},
      {'name': 'Presentation3.pptx', 'size': 3072},
    ];
  }

  // Hàm chọn file
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.files.map((file) => {
          'name': file.name,
          'size': file.size,
          'path': file.path,
        }));
      });
    }
  }                           

  // Hàm xóa file khỏi danh sách
  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  // Hàm sửa tên file
  Future<void> _editFileName(int index) async {
    String currentName = selectedFiles[index]['name'];
    TextEditingController controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa tên file'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Nhập tên mới"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog mà không làm gì
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedFiles[index]['name'] = controller.text; // Cập nhật tên file
                });
                Navigator.of(context).pop(); // Đóng dialog sau khi cập nhật
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // Widget hiển thị danh sách file đã chọn
  Widget _buildFileList() {
    return ListView.builder(
      itemCount: selectedFiles.length,
      itemBuilder: (context, index) {
        var file = selectedFiles[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: Colors.blue),
            title: Text(file['name']),
            subtitle: Text('${(file['size'] / 1024).toStringAsFixed(2)} MB'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: () => _editFileName(index), // Nút sửa
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFile(index), // Nút xóa
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Files - Teams Style',style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFCF1133),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: Icon(Icons.attach_file,color: Colors.white),
                  label: Text('Chọn File' , style: TextStyle(color: Colors.white) // Màu chữ
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCF1133),
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Hàm gửi file (chưa triển khai)
                  },
                  child: Text('Gửi'
                  , style: TextStyle(color: Colors.white), // Màu chữ
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFCF1133),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            selectedFiles.isNotEmpty
                ? Expanded(child: _buildFileList())
                : const Text('Chưa có file nào được chọn.'),
          ],
        ),
      ),
    );
  }
}
