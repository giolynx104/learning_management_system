import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // Thêm thư viện file_picker
import 'dart:io'; // Add this import for File
import 'package:learning_management_system/models/material.dart'
    as MaterialModel;

class FileData {
  final String name;
  final int size;
  final String? path;

  FileData({required this.name, required this.size, this.path});
}

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({Key? key}) : super(key: key);

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  List<MaterialModel.Material> materialData = [];
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedFilePath;
  final String token = 'f3SvYh';
  final String class_id = "000002";

  // Lấy danh sách file
  Future<void> fetchDataGetListMaterial(String token, String classId) async {
    final url = Uri.parse(
        'http://160.30.168.228:8080/it5023e/get_material_list?token=$token&class_id=$classId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        materialData = (data['data'] as List)
            .map((item) => MaterialModel.Material.fromJson(item))
            .toList();
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  // Hàm chọn file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> uploadFile() async {
    if (_selectedFilePath == null ||
        _fileNameController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields and select a file")),
      );
      return;
    }

    String fileName = _fileNameController.text;
    String description = _descriptionController.text;

    var uri = Uri.parse(
        'http://160.30.168.228:8080/it5023e/upload_material'); // URL API của bạn
    var request = http.MultipartRequest('POST', uri)
      ..fields['token'] = token
      ..fields['classId'] = class_id
      ..fields['title'] = fileName
      ..fields['description'] = description
      ..fields['materialType'] = 'PDF'; // Hoặc loại file khác tùy vào yêu cầu

    var file = await http.MultipartFile.fromPath('file', _selectedFilePath!);
    request.files.add(file);

    try {
      var response = await request.send();
      fetchDataGetListMaterial(
          token, class_id); // Cập nhật lại danh sách tài liệu
    } catch (e) {
      // Nếu có lỗi, hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading file: $e")),
      );
    }
  }

  Future<void> editMaterial(int materialId, String newName,
      String newDescription, String? newFilePath) async {
    if (newName.isEmpty || newDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    var uri = Uri.parse('http://160.30.168.228:8080/it5023e/edit_material');
    var request = http.MultipartRequest('POST', uri)
      ..fields['token'] = token
      ..fields['material_id'] = materialId.toString()
      ..fields['title'] = newName
      ..fields['description'] = newDescription;

    // Nếu có file mới, thêm file vào request
    if (newFilePath != null) {
      var file = await http.MultipartFile.fromPath('file', newFilePath);
      request.files.add(file);
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Material updated successfully")),
        );
        fetchDataGetListMaterial(
            token, class_id); // Cập nhật danh sách tài liệu
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update material")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> deleteMaterial(int materialId) async {
    final url = Uri.parse('http://160.30.168.228:8080/it5023e/delete_material');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"token": token, "material_id": materialId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        materialData
            .removeWhere((material) => material.material_id == materialId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Material deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete material")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataGetListMaterial(token, '000002');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: const Text(
            "Manager material",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.red[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.red, size: 40),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Upload New File"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nhập tên tài liệu
                            TextField(
                              controller: _fileNameController,
                              decoration: InputDecoration(
                                labelText: "Filename", // Chỉ định nội dung nhãn
                                labelStyle: TextStyle(
                                    color: Colors.black), // Tùy chỉnh màu chữ
                              ),
                            ),
                            // Nhập mô tả
                            TextField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: "Description",
                                // Chỉ định nội dung nhãn
                                labelStyle: TextStyle(
                                    color: Colors.black), // Tùy chỉnh màu chữ
                              ),
                            ),
                            // Hiển thị đường dẫn file đã chọn
                            if (_selectedFilePath != null)
                              Text(
                                  'Selected File: ${_selectedFilePath!.split('/').last}'),
                            // Nút chọn file
                            ElevatedButton(
                              onPressed: pickFile,
                              child: Text(
                                "Choose File",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Colors.red), // Đặt màu nền thành màu đỏ
                                // Đặt màu nền
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Colors.orangeAccent[200]), // Đặt màu nền thành màu đỏ
                              // Đặt màu nền
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              uploadFile();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Upload",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Colors.green), // Đặt màu nền thành màu đỏ
                              // Đặt màu nền
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: materialData.length,
                itemBuilder: (context, index) {
                  final item = materialData[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      leading: Icon(
                        Icons.insert_drive_file,
                        color: Colors.red,
                        size: 40,
                      ),
                      title: Text(
                        item.material_name ?? 'No Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Đảm bảo các widget con căn trái
                        children: [
                          Text(
                            'Description: ${item.description ?? 'Unknown'}',
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  TextEditingController editNameController =
                                      TextEditingController(
                                          text: item.material_name);
                                  TextEditingController
                                      editDescriptionController =
                                      TextEditingController(
                                          text: item.description);
                                  String? newFilePath; // Đường dẫn file mới

                                  return AlertDialog(
                                    title: Text("Edit Material"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: editNameController,
                                          decoration: InputDecoration(
                                              labelText: "Material Name"),
                                        ),
                                        TextField(
                                          controller: editDescriptionController,
                                          decoration: InputDecoration(
                                              labelText: "Description"),
                                        ),
                                        if (newFilePath != null)
                                          Text(
                                              'New File: ${newFilePath.split('/').last}'),
                                        ElevatedButton(
                                          onPressed: () async {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles();
                                            if (result != null) {
                                              newFilePath = result.files.single
                                                  .path; // Lưu đường dẫn file mới
                                              setState(() {});
                                            }
                                          },
                                          child: Text("Choose New File"),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Đóng dialog
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          editMaterial(
                                            item.material_id,
                                            editNameController.text,
                                            editDescriptionController.text,
                                            newFilePath,
                                          );
                                          Navigator.of(context)
                                              .pop(); // Đóng dialog
                                        },
                                        child: Text("Save"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      height: 200,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Confirm Delete",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            "Are you sure you want to delete this material?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(height: 24.0),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Đóng dialog
                                                },
                                                child: Text("Cancel"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                                onPressed: () {
                                                  deleteMaterial(item
                                                      .material_id); // Gọi hàm xóa
                                                  Navigator.of(context)
                                                      .pop(); // Đóng dialog
                                                },
                                                child: Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
