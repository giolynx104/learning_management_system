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
    Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Registration'),
      ),
      body: Column(
        children: [
          _ClassRegistrationForm(
            classCodeController: _classCodeController,
            classCodeFocusNode: _classCodeFocusNode,
            isRegisterButtonEnabled: _isRegisterButtonEnabled,
            onRegister: _registerClass,
          ),
          Expanded(
            child: _ClassRegistrationTable(
              enteredClassCodes: _enteredClassCodes,
              selectedRowIndices: _selectedRowIndices,
              scrollController: _scrollController,
              horizontalScrollController: _horizontalScrollController,
              onSelectChanged: (int index, bool? isSelected) {
                setState(() {
                  if (isSelected!) {
                    _selectedRowIndices.add(index);
                  } else {
                    _selectedRowIndices.remove(index);
                  }
                });
              },
            ),
          ),
          if (_enteredClassCodes.isNotEmpty)
            _RegistrationActions(
              onSubmit: () {
                // TODO: Implement submit registration functionality
              },
              onRemoveSelected: _removeSelectedClasses,
            ),
          const SizedBox(height: 16),
          const _AvailableClassesLink(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ClassRegistrationForm extends StatelessWidget {
  final TextEditingController classCodeController;
  final FocusNode classCodeFocusNode;
  final bool isRegisterButtonEnabled;
  final VoidCallback onRegister;

  const _ClassRegistrationForm({
    required this.classCodeController,
    required this.classCodeFocusNode,
    required this.isRegisterButtonEnabled,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ClassCodeTextField(
                    controller: classCodeController,
                    focusNode: classCodeFocusNode,
                  ),
                ),
                const SizedBox(width: 10),
                _RegisterButton(
                  isEnabled: isRegisterButtonEnabled,
                  onPressed: onRegister,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ClassCodeTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _ClassCodeTextField({
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: 'Class Code',
        labelStyle: TextStyle(color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        counterText: '',
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: controller.clear,
              )
            : null,
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const _RegisterButton({
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        disabledBackgroundColor: Colors.grey,
      ),
      child: const Text('Register'),
    );
  }
}

class _ClassRegistrationTable extends StatelessWidget {
  final List<String> enteredClassCodes;
  final Set<int> selectedRowIndices;
  final ScrollController scrollController;
  final ScrollController horizontalScrollController;
  final Function(int, bool?) onSelectChanged;

  const _ClassRegistrationTable({
    required this.enteredClassCodes,
    required this.selectedRowIndices,
    required this.scrollController,
    required this.horizontalScrollController,
    required this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return enteredClassCodes.isEmpty
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
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dataTableTheme: DataTableThemeData(
                        headingRowColor: WidgetStateProperty.all(
                          theme.colorScheme.primary,
                        ),
                        headingTextStyle: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: horizontalScrollController,
                        child: DataTable(
                          columnSpacing: 16,
                          horizontalMargin: 16,
                          columns: [
                            DataColumn(
                              label: Text(
                                'Class Code',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Associated Code',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Class Name',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Registration Status',
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: enteredClassCodes
                              .asMap()
                              .entries
                              .map((entry) => DataRow(
                                    selected: selectedRowIndices.contains(entry.key),
                                    onSelectChanged: (isSelected) =>
                                        onSelectChanged(entry.key, isSelected),
                                    cells: [
                                      DataCell(
                                        Text(
                                          entry.value,
                                          style: TextStyle(color: theme.colorScheme.primary),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          'TBD',
                                          style: TextStyle(color: theme.colorScheme.primary),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          'TBD',
                                          style: TextStyle(color: theme.colorScheme.primary),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          'TBD',
                                          style: TextStyle(color: theme.colorScheme.primary),
                                        ),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class _RegistrationActions extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onRemoveSelected;

  const _RegistrationActions({
    required this.onSubmit,
    required this.onRemoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
              onPressed: onRemoveSelected,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
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
    );
  }
}

class _AvailableClassesLink extends StatelessWidget {
  const _AvailableClassesLink();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        // TODO: Implement navigation to available classes list
      },
      child: Text(
        'List of currently available classes',
        style: TextStyle(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
