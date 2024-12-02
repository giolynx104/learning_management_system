import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/models/class_list_model.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
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
  Timer? _refreshTimer;
  List<ClassListItem> _classList = [];
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    debugPrint('ClassManagementScreen - _initializeData started');
    if (!mounted) return;

    try {
      final authState = ref.read(authProvider);
      debugPrint('ClassManagementScreen - authState: $authState');

      return authState.when(
        data: (user) async {
          debugPrint(
              'ClassManagementScreen - auth data received: ${user?.role}');
          if (user == null) {
            if (mounted) context.go(Routes.signin);
            return;
          }

          // Set up the refresh timer only after confirming authentication
          _refreshTimer?.cancel(); // Cancel any existing timer
          _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
            debugPrint('ClassManagementScreen - refresh timer triggered');
            if (mounted) {
              _refreshClassList();
            }
          });

          // Load the initial class list
          await _loadClassList();
        },
        loading: () {
          debugPrint('ClassManagementScreen - auth loading');
          return null;
        },
        error: (e, __) {
          debugPrint('ClassManagementScreen - auth error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error initializing: $e')),
            );
            context.go(Routes.signin);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('ClassManagementScreen - initialization error: $e');
      debugPrint('ClassManagementScreen - stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing: $e')),
        );
        context.go(Routes.signin);
      }
    }
  }

  @override
  void dispose() {
    debugPrint('ClassManagementScreen - dispose called');
    _isDisposed = true;
    _classCodeController.dispose();
    _classCodeFocusNode.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadClassList() async {
    try {
      final authState = ref.read(authProvider);
      final token = authState.token;

      if (token == null) {
        if (mounted) {
          context.go(Routes.signin);
        }
        return;
      }

      final classes =
          await ref.read(classServiceProvider.notifier).getClassList(token);

      if (mounted) {
        setState(() {
          _classList = classes;
        });
      }
    } on UnauthorizedException {
      if (mounted) {
        ref.read(authProvider.notifier).signOut();
        context.go(Routes.signin);
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
    return _classList
        .where(
            (classItem) => classItem.classId.toLowerCase().contains(searchTerm))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredClasses = _getFilteredClasses();
    final authState = ref.watch(authProvider);

    return Material(
      child: Stack(
        children: [
          Column(
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
                      TextField(
                        controller: _classCodeController,
                        focusNode: _classCodeFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Class Code',
                          hintText: 'Enter class code',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Class List - Same for both roles
              Expanded(
                child: _classList.isEmpty
                    ? const Center(child: Text('No classes available'))
                    : filteredClasses.isEmpty
                        ? const Center(child: Text('No matching classes found'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 16,
                              bottom: 80,
                            ),
                            itemCount: filteredClasses.length,
                            itemBuilder: (context, index) {
                              final classItem = filteredClasses[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Class Name Header with Status Badge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.school,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    classItem.className,
                                                    style: theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                      classItem.status)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getStatusColor(
                                                    classItem.status),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              classItem.status,
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                    classItem.status),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            onSelected: (value) =>
                                                _handleClassAction(
                                                    value, classItem),
                                            itemBuilder:
                                                (BuildContext context) {
                                              // Get user role from auth provider
                                              final authState =
                                                  ref.read(authProvider);
                                              final isStudent = authState
                                                      .value?.role
                                                      .toLowerCase() ==
                                                  'student';

                                              return [
                                                // Common options first (for both roles)
                                                const PopupMenuItem(
                                                  value: 'assignment',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.assignment),
                                                      SizedBox(width: 12),
                                                      Text('Assignments'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'files',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.folder),
                                                      SizedBox(width: 12),
                                                      Text('Materials'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'attendance',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.people),
                                                      SizedBox(width: 12),
                                                      Text('Attendance'),
                                                    ],
                                                  ),
                                                ),
                                                // Teacher-specific options at the end
                                                if (!isStudent) ...[
                                                  const PopupMenuDivider(),
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit),
                                                        SizedBox(width: 12),
                                                        Text('Edit Class'),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete,
                                                            color: Colors.red),
                                                        const SizedBox(
                                                            width: 12),
                                                        const Text(
                                                            'Delete Class',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ];
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),

                                      // Class Information Grid
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          _buildInfoChip(
                                            Icons.numbers,
                                            'Class Code',
                                            classItem.classId,
                                            theme.colorScheme.primary,
                                          ),
                                          if (classItem.attachedCode != null &&
                                              classItem
                                                  .attachedCode!.isNotEmpty)
                                            _buildInfoChip(
                                              Icons.link,
                                              'Associated Code',
                                              classItem.attachedCode!,
                                              Colors.purple,
                                            ),
                                          _buildInfoChip(
                                            Icons.category,
                                            'Type',
                                            classItem.classType,
                                            Colors.orange,
                                          ),
                                          _buildInfoChip(
                                            Icons.people,
                                            'Students',
                                            classItem.studentCount.toString(),
                                            Colors.green,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Period and Lecturer Info
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDetailRow(
                                              Icons.calendar_today,
                                              'Period',
                                              '${classItem.startDate} - ${classItem.endDate}',
                                              Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (classItem.lecturerName != null &&
                                          classItem.lecturerName!.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: _buildDetailRow(
                                            Icons.person,
                                            'Lecturer',
                                            classItem.lecturerName!,
                                            Colors.teal,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),

          // FAB - Different actions based on role
          Positioned(
            right: 16,
            bottom: 16,
            child: authState.whenOrNull(
                  data: (user) => user != null
                      ? FloatingActionButton.extended(
                          onPressed: () async {
                            if (user.role == 'STUDENT') {
                              context.pushNamed(Routes.classRegistrationName);
                            } else {
                              final result = await context
                                  .pushNamed<bool>(Routes.createClassName);
                              if (result == true) {
                                _refreshClassList();
                              }
                            }
                          },
                          icon: Icon(
                            user.role == 'STUDENT' ? Icons.add_task : Icons.add,
                          ),
                          label: Text(user.role == 'STUDENT'
                              ? 'Register for Class'
                              : 'Create Class'),
                        )
                      : null,
                ) ??
                const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClassAction(
      String action, ClassListItem classItem) async {
    switch (action) {
      case 'edit':
        context.pushNamed(
          Routes.modifyClassName,
          pathParameters: {'classId': classItem.classId},
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
        context.pushNamed(
          Routes.assignmentsName,
          pathParameters: {'classId': classItem.classId},
        );
        break;
      case 'files':
        context.pushNamed(
          Routes.materialListName,
          pathParameters: {'classId': classItem.classId},
        );
        break;
      case 'attendance':
        try {
          debugPrint('ClassManagementScreen - Handling attendance action');
          final authState = ref.read(authProvider);
          final isStudent = authState.value?.role.toLowerCase() == 'student';
          debugPrint('ClassManagementScreen - User is student: $isStudent');

          if (isStudent) {
            context.pushNamed(
              Routes.studentAttendanceName,
              pathParameters: {'classId': classItem.classId},
            );
          } else {
            context.pushNamed(
              Routes.attendanceManagementName,
              pathParameters: {'classId': classItem.classId},
            );
          }
        } catch (e, stackTrace) {
          debugPrint('ClassManagementScreen - Navigation error: $e');
          debugPrint('ClassManagementScreen - Stack trace: $stackTrace');
        }
        break;
    }
  }

  Future<void> _showDeleteConfirmationDialog(ClassListItem classItem) async {
    bool isDeleting = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                AlertDialog(
                  title: const Text('Delete Class'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Are you sure you want to delete ${classItem.className}?'),
                      if (classItem.studentCount > 0) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Warning: This class has ${classItem.studentCount} enrolled student${classItem.studentCount > 1 ? 's' : ''}.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
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
                                final authState = ref.read(authProvider);
                                final user = authState.value;
                                if (user == null) {
                                  throw Exception('Not authenticated');
                                }

                                await ref
                                    .read(classServiceProvider.notifier)
                                    .deleteClass(
                                      token: user.token ?? '',
                                      classId: classItem.classId,
                                    );

                                if (!mounted) return;
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Class deleted successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _refreshClassList();
                              } catch (e) {
                                setState(() => isDeleting = false);
                                if (!mounted) return;

                                // Close the delete confirmation dialog
                                Navigator.of(dialogContext).pop();

                                // Show error dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Unable to Delete Class'),
                                    content: Text(
                                      e.toString().contains(
                                              'Cannot delete class with existing content')
                                          ? 'This class cannot be deleted because it has existing content (assignments, materials, or enrolled students). Please remove all content and unenroll all students before deleting the class.'
                                          : 'Error deleting class: ${e.toString()}',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
