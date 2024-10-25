import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Class để lưu trữ thông tin file
class FileData {
  final String name;
  final int size;
  final String? path;

  FileData({required this.name, required this.size, this.path});
}

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  List<FileData> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách file mẫu
    selectedFiles = [
      FileData(name: 'Document1.pdf', size: 1024),
      FileData(name: 'Image2.jpg', size: 2048),
      FileData(name: 'Presentation3.pptx', size: 3072),
    ];
  }

  // Hàm chọn file từ thiết bị
  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.files.map((file) =>
            FileData(name: file.name, size: file.size, path: file.path)
        ));
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
    String currentName = selectedFiles[index].name;
    TextEditingController controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tên file'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Nhập tên mới"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedFiles[index] = FileData(
                  name: controller.text,
                  size: selectedFiles[index].size,
                  path: selectedFiles[index].path,
                );
              });
              Navigator.of(context).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Hàm tạo AppBar
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Upload File'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Hàm xây dựng danh sách file đã chọn
  Widget _buildFileList() {
    return ListView.builder(
      itemCount: selectedFiles.length,
      itemBuilder: (context, index) {
        var file = selectedFiles[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: Theme.of(context).colorScheme.primary),
            title: Text(file.name),
            subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} MB'), // Chuyển đổi size sang MB
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _editFileName(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  onPressed: () => _removeFile(index),
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
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nút chọn file và nút gửi
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _selectFiles,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Chọn File'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add functionality to send files
                  },
                  child: const Text('Gửi'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Kiểm tra nếu có file nào được chọn
            selectedFiles.isNotEmpty
                ? Expanded(child: _buildFileList()) // Hiện danh sách file
                : const Center(child: Text('Chưa có file nào được chọn.')), // Thông báo không có file
          ],
        ),
      ),
    );
  }
}
