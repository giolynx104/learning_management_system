import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<UploadFileScreen> {
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload File'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () => _pickFile(),
                  tooltip: 'Upload Image',
                ),
                IconButton(
                  icon: Icon(Icons.video_file),
                  onPressed: () => _pickFile(),
                  tooltip: 'Upload Video',
                ),
                IconButton(
                  icon: Icon(Icons.insert_drive_file),
                  onPressed: () => _pickFile(),
                  tooltip: 'Upload Document',
                ),
              ],
            ),
          ),
          Expanded(
            child: _fileName != null
                ? ListTile(
              leading: Icon(Icons.file_present),
              title: Text('Selected File: $_fileName'),
            )
                : Center(
              child: Text('No file selected'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement file upload functionality here
            },
            child: Text('Upload'),
          ),
        ],
      ),
    );
  }
}
