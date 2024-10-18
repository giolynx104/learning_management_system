import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Widget> _messages = [];
  final ImagePicker _picker = ImagePicker();  // Image picker để chọn ảnh

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.red[100], // Tông nền đỏ nhạt cho tin nhắn
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(_controller.text),
          ),
        );
        _controller.clear();
      });
    }
  }

  // Hàm chụp ảnh hoặc chọn ảnh từ thư viện
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _messages.add(
          Container(
            padding: EdgeInsets.all(8.0),
            child: Image.file(
              File(pickedFile.path),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Colors.red,  // Tông màu đỏ cho AppBar
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];  // Hiển thị tin nhắn và ảnh
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.red),  // Icon chụp ảnh
                  onPressed: () => _pickImage(ImageSource.camera),  // Chọn ảnh từ máy ảnh
                ),
                IconButton(
                  icon: Icon(Icons.photo, color: Colors.red),  // Icon chọn ảnh từ thư viện
                  onPressed: () => _pickImage(ImageSource.gallery),  // Chọn ảnh từ thư viện
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      fillColor: Colors.white,  // Tông nền trắng cho input
                      filled: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.red),  // Icon gửi tin nhắn
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
