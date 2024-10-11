// import 'package:flutter/material.dart';
//
// class CreateSurveyScreen extends StatefulWidget {
//   @override
//   _CreateSurveyScreenState createState() => _CreateSurveyScreenState();
// }
//
// class _CreateSurveyScreenState extends State<CreateSurveyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   DateTime? _selectedDate;
//   // String? _endTime;
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (pickedDate != null && pickedDate != _selectedDate) {
//       setState(() {
//         _selectedDate = pickedDate;
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red[900],
//         centerTitle: true,
//         title: const SizedBox(
//           height: 100,
//           child:  Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Padding(padding: EdgeInsets.all(20.0),
//                   child: Text('HUST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white))
//               )
//               ,
//               Padding(padding: EdgeInsets.all(20.0),
//                   child:  Text(
//                     'CREATE SURVEY',
//                     style: TextStyle(fontSize: 20, color: Colors.white),
//                   )
//               )
//
//             ],
//           ),
//         ),
//
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.of(context).pop(); // Navigate back
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//
//         child:
//         Container(
//           decoration: BoxDecoration(
//             // color: Colors.blue[100]
//           ),
//           child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     decoration: const InputDecoration(
//                         labelText: 'Tiêu đề',
//                         border: OutlineInputBorder(),
//                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0))
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Tiêu đề';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16.0),
//
//                   // TextField for "Mô tả"
//                   TextFormField(
//                     decoration: const InputDecoration(
//                       labelText: 'Lý do',
//                       border: OutlineInputBorder(),
//                     ),
//                     maxLines: 6,
//                   ),
//                   const SizedBox(height: 30.0),
//
//                   // Button for "Tải tài liệu lên"
//                   Center( child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red[900],
//                     ),
//                     onPressed: () {
//                       // Logic to upload file
//                     },
//                     icon: const Icon(Icons.upload_file, color: Colors.white),
//                     label: const Text('Tải minh chứng',
//                         style: TextStyle(color: Colors.white)),
//                   ),),
//
//                   const SizedBox(height: 16.0),
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red[900],
//                         padding: EdgeInsets.zero, // Xóa padding mặc định
//                         minimumSize: Size(0, 0),  // Đảm bảo nút chỉ có kích cỡ tối thiểu theo văn bản
//                       ),
//                       onPressed: () => _selectDate(context),
//                       child: Text(
//                         _selectedDate == null
//                             ? 'Chọn ngày'
//                             : 'Ngày nghỉ phép: ${_selectedDate!.toLocal()}'.split(' ')[0],
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32.0),
//                   // Submit button
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red[900], // Button color
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24.0, vertical: 12.0),
//                       ),
//                       onPressed: () {
//                         if (_formKey.currentState!.validate()) {
//                           // Submit logic
//                         }
//                       },
//                       child: const Text('Submit',
//                           style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//         )
//
//         ),
//       ),
//     );
//   }
// }
