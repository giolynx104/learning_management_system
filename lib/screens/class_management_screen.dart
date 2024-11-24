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
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
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
                                                _handleClassAction(
                                                    value, classItem),
                                            itemBuilder:
                                                (BuildContext context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit Class'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete Class',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                              const PopupMenuItem(
                                                value: 'assignment',
                                                child: Text('Assignments'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'files',
                                                child: Text('Materials'),
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
                                      _buildInfoRow(
                                          'Class Code', classItem.classId),
                                      if (classItem.attachedCode != null &&
                                          classItem.attachedCode!.isNotEmpty)
                                        _buildInfoRow('Associated Code',
                                            classItem.attachedCode!),
                                      _buildInfoRow(
                                          'Type', classItem.classType),
                                      _buildInfoRow('Status', classItem.status),
                                      _buildInfoRow('Students',
                                          '${classItem.studentCount}'),
                                      _buildInfoRow('Period',
                                          '${classItem.startDate} - ${classItem.endDate}'),
                                      if (classItem.lecturerName != null &&
                                          classItem.lecturerName!.isNotEmpty)
                                        _buildInfoRow('Lecturer',
                                            classItem.lecturerName!),
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
                          onPressed: () {
                            if (user.role == 'STUDENT') {
                              context.pushNamed(Routes.classRegistrationName);
                            } else {
                              context.pushNamed(Routes.createClassName);
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
        final authState = ref.read(authProvider);
        final isStudent = authState.value?.role.toLowerCase() == 'student';

        if (isStudent) {
          context.pushNamed(
            Routes.studentSurveyListName,
            pathParameters: {'classId': classItem.classId},
          );
        } else {
          context.pushNamed(
            Routes.teacherSurveyListName,
            pathParameters: {'classId': classItem.classId},
          );
        }
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
              Routes.rollCallName,
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
      ),
    );
  }
}
