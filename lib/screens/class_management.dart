import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:learning_management_system/screens/create_class_screen.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ClassManagementScreenState createState() => ClassManagementScreenState();
}

class ClassManagementScreenState extends State<ClassManagementScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  final FocusNode _classCodeFocusNode = FocusNode();
  final List<String> _searchedClassCodes = [];
  final Set<int> _selectedRowIndices = {};
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool _isSearchButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _classCodeFocusNode.requestFocus();
    });
    _classCodeController.addListener(_updateSearchButtonState);
  }

  @override
  void dispose() {
    _classCodeController.removeListener(_updateSearchButtonState);
    _classCodeController.dispose();
    _classCodeFocusNode.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _updateSearchButtonState() {
    setState(() {
      _isSearchButtonEnabled = _classCodeController.text.trim().length == 6;
    });
  }

  void _searchClass() {
    final classCode = _classCodeController.text.trim();
    if (classCode.length == 6 && !_searchedClassCodes.contains(classCode)) {
      setState(() {
        _searchedClassCodes.add(classCode);
        _classCodeController.clear();
      });
      log('Searched class code: $classCode');
    } else if (_searchedClassCodes.contains(classCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This class code has already been searched.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeSelectedClasses() {
    setState(() {
      _searchedClassCodes.removeWhere((classCode) =>
          _selectedRowIndices.contains(_searchedClassCodes.indexOf(classCode)));
      _selectedRowIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
      ),
      body: Column(
        children: [
          _ClassSearchForm(
            classCodeController: _classCodeController,
            classCodeFocusNode: _classCodeFocusNode,
            isSearchButtonEnabled: _isSearchButtonEnabled,
            onSearch: _searchClass,
          ),
          Expanded(
            child: _ClassManagementTable(
              searchedClassCodes: _searchedClassCodes,
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
          _ManagementActions(
            onCreateClass: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateClassScreen()),
              );
            },
            onModifyClass: () {
              // TODO: Navigate to modify class screen
            },
          ),
          const SizedBox(height: 16),
          const _AvailableClassesLink(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ClassSearchForm extends StatelessWidget {
  final TextEditingController classCodeController;
  final FocusNode classCodeFocusNode;
  final bool isSearchButtonEnabled;
  final VoidCallback onSearch;

  const _ClassSearchForm({
    required this.classCodeController,
    required this.classCodeFocusNode,
    required this.isSearchButtonEnabled,
    required this.onSearch,
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
                _SearchButton(
                  isEnabled: isSearchButtonEnabled,
                  onPressed: onSearch,
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

class _SearchButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const _SearchButton({
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
      child: const Text('Search'),
    );
  }
}

class _ClassManagementTable extends StatelessWidget {
  final List<String> searchedClassCodes;
  final Set<int> selectedRowIndices;
  final ScrollController scrollController;
  final ScrollController horizontalScrollController;
  final Function(int, bool?) onSelectChanged;

  const _ClassManagementTable({
    required this.searchedClassCodes,
    required this.selectedRowIndices,
    required this.scrollController,
    required this.horizontalScrollController,
    required this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
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
                    ],
                    rows: searchedClassCodes.isEmpty
                        ? [
                            DataRow(
                              cells: [
                                DataCell(Text('No data', style: TextStyle(color: theme.colorScheme.primary))),
                                DataCell(Text('No data', style: TextStyle(color: theme.colorScheme.primary))),
                                DataCell(Text('No data', style: TextStyle(color: theme.colorScheme.primary))),
                              ],
                            ),
                          ]
                        : searchedClassCodes
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

class _ManagementActions extends StatelessWidget {
  final VoidCallback onCreateClass;
  final VoidCallback onModifyClass;

  const _ManagementActions({
    required this.onCreateClass,
    required this.onModifyClass,
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
              onPressed: onCreateClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Create Class'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onModifyClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Modify Class'),
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
