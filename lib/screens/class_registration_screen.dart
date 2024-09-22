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
                          maxLength: 6,
                          decoration: InputDecoration(
                            labelText: 'Class Code',
                            labelStyle: TextStyle(color: Colors.red[900]!),
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
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isRegisterButtonEnabled ? _registerClass : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: _enteredClassCodes.isEmpty
                ? const Center(
                    child: Text('No classes registered yet'),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red[900]!,
                              width: 2,
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dataTableTheme: DataTableThemeData(
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.red[900],
                                ),
                                headingTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: DataTable(
                                      columnSpacing: 16,
                                      horizontalMargin: 16,
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'Class Code',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Associated Code',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Class Name',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: _enteredClassCodes
                                          .asMap()
                                          .entries
                                          .map((entry) => DataRow(
                                                selected: _selectedRowIndices
                                                    .contains(entry.key),
                                                onSelectChanged: (isSelected) {
                                                  setState(() {
                                                    if (isSelected!) {
                                                      _selectedRowIndices
                                                          .add(entry.key);
                                                    } else {
                                                      _selectedRowIndices
                                                          .remove(entry.key);
                                                    }
                                                  });
                                                },
                                                cells: [
                                                  DataCell(
                                                    Text(
                                                      entry.value,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[900]),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      'TBD',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[900]),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      'TBD',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[900]),
                                                    ),
                                                  ),
                                                ],
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_enteredClassCodes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement submit registration functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text('Submit Registration'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _removeSelectedClasses,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        'Remove Selected Classes',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
