import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/models/class_list_model.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/exceptions/unauthorized_exception.dart';
import 'dart:async';

class ClassManagementScreen extends ConsumerStatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ConsumerState<ClassManagementScreen> createState() =>
      ClassManagementScreenState();
}

class ClassManagementScreenState extends ConsumerState<ClassManagementScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  final FocusNode _classCodeFocusNode = FocusNode();
  late Timer _refreshTimer;
  List<ClassListItem> _classList = [];

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _refreshClassList();
      }
    });
    _loadClassList();
  }

  @override
  void dispose() {
    _classCodeController.dispose();
    _classCodeFocusNode.dispose();
    _refreshTimer.cancel();
    super.dispose();
  }

  Future<void> _loadClassList() async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }
      final classes = await ref
          .read(classServiceProvider.notifier)
          .getClassList(authState.token);
      if (mounted) {
        setState(() {
          _classList = classes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _refreshClassList() {
    _loadClassList();
  }

  List<ClassListItem> _getFilteredClasses() {
    if (_classList.isEmpty) {
      return []; // Return empty list if there are no classes at all
    }
    
    final searchTerm = _classCodeController.text.trim().toLowerCase();
    if (searchTerm.isEmpty) {
      return _classList; // Return all classes when search is empty
    }
    return _classList.where((classItem) => 
      classItem.classId.toLowerCase().contains(searchTerm)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredClasses = _getFilteredClasses();

    return Scaffold(
      body: Column(
        children: [
          // Search Class Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Search Class by Code',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _classCodeController,
                      focusNode: _classCodeFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Class Code',
                        hintText: 'Enter class code',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Class List
          Expanded(
            child: _classList.isEmpty
                ? const Center(
                    child: Text('No classes available'),  // Changed message for empty class list
                  )
                : filteredClasses.isEmpty
                    ? const Center(
                        child: Text('No matching classes found'),  // Changed message for no search results
                      )
                    : Stack(
                        children: [
                          ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredClasses.length,
                            itemBuilder: (context, index) {
                              final classItem = filteredClasses[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              classItem.className,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) =>
                                                _handleClassAction(value, classItem),
                                            itemBuilder: (BuildContext context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit Class'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete Class',
                                                    style:
                                                        TextStyle(color: Colors.red)),
                                              ),
                                              const PopupMenuItem(
                                                value: 'assignment',
                                                child: Text('Assignments'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'files',
                                                child: Text('Files'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'attendance',
                                                child: Text('Attendance'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      _buildInfoRow('Class Code', classItem.classId),
                                      if (classItem.attachedCode != null &&
                                          classItem.attachedCode!.isNotEmpty)
                                        _buildInfoRow('Associated Code',
                                            classItem.attachedCode!),
                                      _buildInfoRow('Type', classItem.classType),
                                      _buildInfoRow('Status', classItem.status),
                                      _buildInfoRow(
                                          'Students', '${classItem.studentCount}'),
                                      _buildInfoRow('Period',
                                          '${classItem.startDate} - ${classItem.endDate}'),
                                      if (classItem.lecturerName != null &&
                                          classItem.lecturerName!.isNotEmpty)
                                        _buildInfoRow(
                                            'Lecturer', classItem.lecturerName!),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: FloatingActionButton(
                              onPressed: () async {
                                final result =
                                    await context.push(Routes.nestedCreateClass);
                                if (result == true) {
                                  _refreshClassList();
                                }
                              },
                              child: const Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  void _handleClassAction(String action, ClassListItem classItem) {
    switch (action) {
      case 'edit':
        debugPrint(
            'ClassManagementScreen - ClassId: ${classItem.classId}, Type: ${classItem.classId.runtimeType}');
        context.pushNamed(
          Routes.modifyClass,
          pathParameters: {'classId': classItem.classId.toString()},
        ).then((result) {
          if (result == true) {
            _refreshClassList();
          }
        });
        break;
      case 'delete':
        _showDeleteConfirmationDialog(classItem);
        break;
      case 'assignment':
        context.push(Routes.nestedTeacherSurveyList);
        break;
      case 'files':
        context.push(Routes.nestedUploadFile);
        break;
      case 'attendance':
        context.push(Routes.nestedRollCallAction);
        break;
    }
  }

  Future<void> _showDeleteConfirmationDialog(ClassListItem classItem) async {
    bool isDeleting = false;

    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          // Use StatefulBuilder to update dialog state
          builder: (context, setState) {
            return Stack(
              children: [
                AlertDialog(
                  title: const Text('Delete Class'),
                  content: Text(
                      'Are you sure you want to delete ${classItem.className}?'),
                  actions: [
                    TextButton(
                      onPressed: isDeleting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setState(() => isDeleting = true);
                              try {
                                final authState =
                                    await ref.read(authProvider.future);
                                if (authState == null) {
                                  throw Exception('Not authenticated');
                                }

                                await ref
                                    .read(classServiceProvider.notifier)
                                    .deleteClass(
                                      token: authState.token,
                                      classId: classItem.classId,
                                    );

                                if (!mounted) return;
                                Navigator.of(dialogContext)
                                    .pop(); // Close the dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Class deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _refreshClassList();
                              } catch (e) {
                                setState(() => isDeleting =
                                    false); // Reset loading state on error
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting class: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                if (isDeleting)
                  const Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
