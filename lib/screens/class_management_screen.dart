import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/routes.dart';

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
    } else if (_searchedClassCodes.contains(classCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This class code has already been searched')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Class',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _classCodeController,
                              focusNode: _classCodeFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Class Code',
                                hintText: 'Enter 6-digit code',
                                prefixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(),
                              ),
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              onSubmitted: (_) => _isSearchButtonEnabled ? _searchClass() : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                            onPressed: _isSearchButtonEnabled ? _searchClass : null,
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: PaginatedDataTable(
                      header: Text(
                        'Search Results',
                        style: theme.textTheme.titleLarge,
                      ),
                      columns: const [
                        DataColumn(label: Text('Class Code')),
                        DataColumn(label: Text('Associated Code')),
                        DataColumn(label: Text('Class Name')),
                      ],
                      source: _ClassDataSource(
                        data: _searchedClassCodes,
                        selectedIndices: _selectedRowIndices,
                        onSelectChanged: (index, selected) {
                          if (selected != null) {
                            setState(() {
                              if (selected) {
                                _selectedRowIndices.add(index);
                              } else {
                                _selectedRowIndices.remove(index);
                              }
                            });
                          }
                        },
                      ),
                      rowsPerPage: 5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.push(Routes.createClass),
                      child: const Text('Create Class'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => context.push(Routes.modifyClass),
                      child: const Text('Modify Class'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassDataSource extends DataTableSource {
  final List<String> data;
  final Set<int> selectedIndices;
  final Function(int, bool?) onSelectChanged;

  _ClassDataSource({
    required this.data,
    required this.selectedIndices,
    required this.onSelectChanged,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    return DataRow(
      selected: selectedIndices.contains(index),
      onSelectChanged: (selected) => onSelectChanged(index, selected),
      cells: [
        DataCell(Text(data[index])),
        const DataCell(Text('TBD')),
        const DataCell(Text('TBD')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => selectedIndices.length;
}
