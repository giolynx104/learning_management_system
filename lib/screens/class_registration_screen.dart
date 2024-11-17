import 'package:flutter/material.dart';
import 'dart:developer';

//TODO: Make the table first column fixed position when scrolling

class ClassRegistrationScreen extends StatefulWidget {
  const ClassRegistrationScreen({super.key});

  @override
  ClassRegistrationScreenState createState() => ClassRegistrationScreenState();
}

class ClassRegistrationScreenState extends State<ClassRegistrationScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  final FocusNode _classCodeFocusNode = FocusNode();
  final List<String> _enteredClassCodes = [];
  final Set<int> _selectedRowIndices = {};
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isRegisterButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _classCodeFocusNode.requestFocus();
    });
    _classCodeController.addListener(_updateRegisterButtonState);
  }

  @override
  void dispose() {
    _classCodeController.removeListener(_updateRegisterButtonState);
    _classCodeController.dispose();
    _classCodeFocusNode.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _updateRegisterButtonState() {
    setState(() {
      _isRegisterButtonEnabled = _classCodeController.text.trim().length == 6;
    });
  }

  void _registerClass() {
    final classCode = _classCodeController.text.trim();
    if (classCode.length == 6 && !_enteredClassCodes.contains(classCode)) {
      setState(() {
        _enteredClassCodes.add(classCode);
        _classCodeController.clear();
      });
      log('Registered class code: $classCode');
    } else if (_enteredClassCodes.contains(classCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This class code has already been registered.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeSelectedClasses() {
    setState(() {
      _enteredClassCodes.removeWhere((classCode) =>
          _selectedRowIndices.contains(_enteredClassCodes.indexOf(classCode)));
      _selectedRowIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Registration'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _classCodeController,
                  focusNode: _classCodeFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Class Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isRegisterButtonEnabled ? _registerClass : null,
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildClassTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _horizontalScrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Select')),
            DataColumn(label: Text('Class Code')),
            // ... other columns
          ],
          rows: _enteredClassCodes.asMap().entries.map((entry) {
            final index = entry.key;
            final classCode = entry.value;
            return DataRow(
              cells: [
                DataCell(
                  Checkbox(
                    value: _selectedRowIndices.contains(index),
                    onChanged: (bool? value) {
                      if (value != null) {
                        setState(() {
                          if (value) {
                            _selectedRowIndices.add(index);
                          } else {
                            _selectedRowIndices.remove(index);
                          }
                        });
                      }
                    },
                  ),
                ),
                DataCell(Text(classCode)),
                // ... other cells
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
