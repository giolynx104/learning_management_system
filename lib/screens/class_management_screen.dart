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
  ConsumerState<ClassManagementScreen> createState() => ClassManagementScreenState();
}

class ClassManagementScreenState extends ConsumerState<ClassManagementScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  final FocusNode _classCodeFocusNode = FocusNode();
  bool _isSearchButtonEnabled = false;
  late Timer _refreshTimer;

  // Add a key to force refresh the FutureBuilder
  final _refreshKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _classCodeController.addListener(_updateSearchButtonState);
    
    // Set up periodic refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {}); // This will trigger a rebuild and refresh the class list
      }
    });
  }

  @override
  void dispose() {
    _classCodeController.removeListener(_updateSearchButtonState);
    _classCodeController.dispose();
    _classCodeFocusNode.dispose();
    _refreshTimer.cancel(); // Cancel timer when disposing
    super.dispose();
  }

  void _updateSearchButtonState() {
    setState(() {
      _isSearchButtonEnabled = _classCodeController.text.trim().length == 6;
    });
  }

  Future<void> _searchClass() async {
    final classCode = _classCodeController.text.trim();
    if (classCode.length == 6) {
      // TODO: Implement class search by code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class search to be implemented')),
      );
      _classCodeController.clear();
    }
  }

  Future<List<ClassListItem>> _getClassList() async {
    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }
      return await ref.read(classServiceProvider.notifier).getClassList(authState.token);
    } on UnauthorizedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate to login screen
        context.go(Routes.signin);
      }
      return [];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      return [];
    }
  }

  void _handleClassAction(String action, ClassListItem classItem) {
    switch (action) {
      case 'edit':
        debugPrint('ClassManagementScreen - ClassId: ${classItem.classId}, Type: ${classItem.classId.runtimeType}');
        context.pushNamed(
          Routes.modifyClass,
          pathParameters: {'classId': classItem.classId.toString()},
        ).then((result) {
          if (result == true) {
            // Class was edited successfully
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
        return StatefulBuilder( // Use StatefulBuilder to update dialog state
          builder: (context, setState) {
            return Stack(
              children: [
                AlertDialog(
                  title: const Text('Delete Class'),
                  content: Text('Are you sure you want to delete ${classItem.className}?'),
                  actions: [
                    TextButton(
                      onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setState(() => isDeleting = true);
                              try {
                                final authState = await ref.read(authProvider.future);
                                if (authState == null) {
                                  throw Exception('Not authenticated');
                                }

                                await ref.read(classServiceProvider.notifier).deleteClass(
                                  token: authState.token,
                                  classId: classItem.classId,
                                );

                                if (!mounted) return;
                                Navigator.of(dialogContext).pop(); // Close the dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Class deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _refreshClassList();
                              } catch (e) {
                                setState(() => isDeleting = false); // Reset loading state on error
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting class: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

  // Add method to handle refresh
  void _refreshClassList() {
    setState(() {
      _refreshKey.currentState?.setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40, // Match button height
                            child: TextField(
                              controller: _classCodeController,
                              focusNode: _classCodeFocusNode,
                              decoration: const InputDecoration(
                                labelText: 'Class Code',
                                hintText: 'Enter 6-digit code',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              maxLength: 6,
                              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        FilledButton(
                          onPressed: _isSearchButtonEnabled ? _searchClass : null,
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Class List
          Expanded(
            child: FutureBuilder<List<ClassListItem>>(
              key: _refreshKey, // Add the key here
              future: _getClassList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final classes = snapshot.data ?? [];

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classItem = classes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(
                              classItem.className,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Type: ${classItem.classType}'),
                                Text('Students: ${classItem.studentCount}'),
                                Text('Period: ${classItem.startDate} - ${classItem.endDate}'),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) => _handleClassAction(value, classItem),
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit Class'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Class', style: TextStyle(color: Colors.red)),
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
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: () async {
                          final result = await context.push(Routes.nestedCreateClass);
                          if (result == true) {
                            // Class was created successfully
                            _refreshClassList();
                          }
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
