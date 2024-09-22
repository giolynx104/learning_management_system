import 'package:flutter/material.dart';
import 'dart:developer';

class ClassRegistrationScreen extends StatefulWidget {
  const ClassRegistrationScreen({super.key});

  @override
  ClassRegistrationScreenState createState() => ClassRegistrationScreenState();
}

class ClassRegistrationScreenState extends State<ClassRegistrationScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  final FocusNode _classCodeFocusNode = FocusNode();
  final List<String> _enteredClassCodes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _classCodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _classCodeController.dispose();
    _classCodeFocusNode.dispose();
    super.dispose();
  }

  void _registerClass() {
    final classCode = _classCodeController.text.trim();
    if (classCode.isNotEmpty) {
      setState(() {
        _enteredClassCodes.add(classCode);
        _classCodeController.clear();
      });
      log('Registered class code: $classCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _classCodeController,
                      focusNode: _classCodeFocusNode,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Class Code',
                        labelStyle: TextStyle(
                            color: Colors.red[900]!),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red[900]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red[900]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red[900]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _registerClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _enteredClassCodes.isEmpty
                  ? const Center(
                      child: Text('No classes registered yet'),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Class Code')),
                          DataColumn(label: Text('Associated Class Code')),
                          DataColumn(label: Text('Class Name')),
                        ],
                        rows: _enteredClassCodes.map((code) => DataRow(
                          cells: [
                            DataCell(Text(code)),
                            const DataCell(Text('TBD')),
                            const DataCell(Text('TBD')),
                          ],
                        )).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
