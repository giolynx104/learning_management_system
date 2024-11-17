import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/models/class_model.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:go_router/go_router.dart';

class ClassRegistrationScreen extends ConsumerStatefulWidget {
  const ClassRegistrationScreen({super.key});

  @override
  ConsumerState<ClassRegistrationScreen> createState() => ClassRegistrationScreenState();
}

class ClassRegistrationScreenState extends ConsumerState<ClassRegistrationScreen> {
  final TextEditingController _classCodeController = TextEditingController();
  final List<String> _selectedClassCodes = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }

  Future<void> _searchClass() async {
    final classCode = _classCodeController.text.trim();
    
    // Validate class code format
    if (classCode.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(classCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class code must be exactly 6 digits'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }

      final classInfo = await ref.read(classServiceProvider.notifier).getBasicClassInfo(
        token: authState.token,
        classId: classCode,
      );

      if (!mounted) return;

      if (classInfo != null) {
        _showClassInfoDialog(classInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerClasses() async {
    if (_selectedClassCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one class')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) {
        throw Exception('Not authenticated');
      }

      final results = await ref.read(classServiceProvider.notifier).registerClasses(
        token: authState.token,
        classIds: _selectedClassCodes,
      );

      if (!mounted) return;

      // Show results dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: results.map((result) => ListTile(
              leading: Icon(
                result['status'] == 'SUCCESS' ? Icons.check_circle : Icons.error,
                color: result['status'] == 'SUCCESS' ? Colors.green : Colors.red,
              ),
              title: Text('Class ${result['class_id']}'),
              subtitle: Text(result['status'] ?? ''),
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop(true); // Return to class list
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Search section with elegant design
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Class Code',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _classCodeController,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.onPrimary,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            counterText: '', // Remove the digit counter
                          ),
                          maxLength: 6,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _searchClass,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(48, 48),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Selected classes list with elegant cards
        Expanded(
          child: _selectedClassCodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes selected',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _selectedClassCodes.length,
                  itemBuilder: (context, index) {
                    final classCode = _selectedClassCodes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            classCode.substring(0, 2),
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        title: Text(
                          'Class Code: $classCode',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          onPressed: () {
                            setState(() {
                              _selectedClassCodes.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Register button with elegant design
        if (_selectedClassCodes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerClasses,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Register Selected Classes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  // Beautiful class info dialog
  void _showClassInfoDialog(ClassModel classInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.school, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Text('Class Information'),
          ],
        ),
        content: SizedBox(  // Added fixed width container
          width: 400,
          child: SingleChildScrollView(  // Make content scrollable
            child: Column(
              mainAxisSize: MainAxisSize.min,  // Important!
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classInfo.className,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDialogInfoRow(
                  icon: Icons.numbers,
                  label: 'Class Code',
                  value: classInfo.classId,
                ),
                _buildDialogInfoRow(
                  icon: Icons.category,
                  label: 'Type',
                  value: classInfo.classType,
                ),
                _buildDialogInfoRow(
                  icon: Icons.people,
                  label: 'Capacity',
                  value: '${classInfo.studentCount}/${classInfo.maxStudentAmount ?? "∞"}',
                ),
                _buildDialogInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Period',
                  value: '${classInfo.startDate} - ${classInfo.endDate}',
                ),
                _buildDialogInfoRow(
                  icon: Icons.check_circle,
                  label: 'Status',
                  value: classInfo.status,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(  // Using FilledButton for better emphasis
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (!_selectedClassCodes.contains(classInfo.classId)) {
                  _selectedClassCodes.add(classInfo.classId);
                }
              });
              _classCodeController.clear();
            },
            child: const Text('Add to List'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
