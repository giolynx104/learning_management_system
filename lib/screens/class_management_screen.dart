import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/models/class_list_model.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class ClassManagementScreen extends ConsumerStatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ConsumerState<ClassManagementScreen> createState() => ClassManagementScreenState();
}

class ClassManagementScreenState extends ConsumerState<ClassManagementScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  final FocusNode _classCodeFocusNode = FocusNode();
  bool _isSearchButtonEnabled = false;

  @override
  void initState() {
    super.initState();
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
        context.goNamed(
          Routes.modifyClass,
          pathParameters: {'classId': classItem.classId.toString()},
        );
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
                        onPressed: () => context.push(Routes.nestedCreateClass),
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
