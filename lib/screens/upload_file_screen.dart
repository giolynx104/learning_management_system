import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  List<Map<String, dynamic>> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    selectedFiles = [
      {'name': 'Document1.pdf', 'size': 1024},
      {'name': 'Image2.jpg', 'size': 2048},
      {'name': 'Presentation3.pptx', 'size': 3072},
    ];
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
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

  void _removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  Future<void> _editFileName(int index) async {
    String currentName = selectedFiles[index]['name'];
    TextEditingController controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sửa tên file'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nhập tên mới"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedFiles[index]['name'] = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFileList() {
    return ListView.builder(
      itemCount: selectedFiles.length,
      itemBuilder: (context, index) {
        var file = selectedFiles[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: Icon(Icons.insert_drive_file, color: Theme.of(context).colorScheme.primary),
            title: Text(file['name']),
            subtitle: Text('${(file['size'] / 1024).toStringAsFixed(2)} MB'),
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
      appBar: AppBar(
        title: Text('Upload File',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.onPrimary),
                  label: Text('Chọn File',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    'Gửi',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
