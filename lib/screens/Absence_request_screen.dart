import 'package:flutter/material.dart';

class AbsenceRequestScreen extends StatefulWidget {
  @override
  _AbsenceRequestScreen createState() => _AbsenceRequestScreen();
}

class _AbsenceRequestScreen extends State<AbsenceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _startTime;
  String? _endTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        centerTitle: true,
        title: const SizedBox(
          height: 100,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center, // can giua
            children: [
              Padding(padding: EdgeInsets.all(20.0),
                  child: Text('HUST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white))
              )
              ,
              Padding(padding: EdgeInsets.all(20.0),
                  child:  Text(
                    'CREATE SURVEY',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )
              )

            ],
          ),
        ),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextField for "Tên bài kiểm tra"
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Tên bài kiểm tra*',
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0))),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the test name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // TextField for "Mô tả"
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),

              // Button for "Tải tài liệu lên"
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                ),
                onPressed: () {
                  // Logic to upload file
                },
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: const Text('Tải tài liệu lên',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16.0),

              // Dropdowns for "Bắt đầu" and "Kết thúc"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Bắt đầu',
                        border: OutlineInputBorder(),
                      ),
                      value: _startTime,
                      onChanged: (newValue) {
                        setState(() {
                          _startTime = newValue;
                        });
                      },
                      items: <String>['8:00', '9:00', '10:00']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kết thúc',
                        border: OutlineInputBorder(),
                      ),
                      value: _endTime,
                      onChanged: (newValue) {
                        setState(() {
                          _endTime = newValue;
                        });
                      },
                      items: <String>['10:00', '11:00', '12:00']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              // Submit button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900], // Button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Submit logic
                    }
                  },
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
