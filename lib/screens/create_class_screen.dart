import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/services/storage_service.dart';

class CreateClassScreen extends HookConsumerWidget {
  const CreateClassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final classCodeController = useTextEditingController();
    final associatedClassCodeController = useTextEditingController();
    final classNameController = useTextEditingController();
    final courseCodeController = useTextEditingController();
    final maxStudentsController = useTextEditingController();
    final classType = useState<String?>(null);
    final startDate = useState<DateTime?>(null);
    final endDate = useState<DateTime?>(null);

    Future<void> handleCreateClass() async {
      if (formKey.currentState?.validate() ?? false) {
        try {
          final classService = ref.read(classServiceProvider.notifier);
          
          final token = await StorageService().getToken();
          print('Debug - Stored token: $token');
          
          final authState = await ref.read(authProvider.future);
          print('Debug - Auth state: $authState');
          
          if (authState == null) {
            throw Exception('Not authenticated');
          }
          
          print('Debug - Auth token: ${authState.token}');
          
          await classService.createClass(
            token: authState.token,
            classId: classCodeController.text,
            className: classNameController.text,
            classType: classType.value!,
            startDate: startDate.value!,
            endDate: endDate.value!,
            maxStudentAmount: int.parse(maxStudentsController.text),
            attachedCode: associatedClassCodeController.text.isNotEmpty 
              ? associatedClassCodeController.text 
              : null,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Class created successfully')),
            );
            context.pop();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create class: ${e.toString()}')),
            );
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text('Create Class', style: TextStyle(color: theme.colorScheme.onPrimary)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a New Class',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: classCodeController,
                labelText: 'Class Code',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a class code' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: associatedClassCodeController,
                labelText: 'Associated Class Code',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter an associated class code' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: classNameController,
                labelText: 'Class Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a class name' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: courseCodeController,
                labelText: 'Course Code',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a course code' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: classType.value,
                labelText: 'Class Type',
                items: const [
                  DropdownMenuItem(value: 'theory', child: Text('Theory')),
                  DropdownMenuItem(value: 'exercise', child: Text('Exercise')),
                  DropdownMenuItem(value: 'both', child: Text('Both')),
                ],
                onChanged: (value) => classType.value = value,
                validator: (value) =>
                    value == null ? 'Please select a class type' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                labelText: 'Start Date',
                selectedDate: startDate.value,
                onDateSelected: (date) => startDate.value = date,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                labelText: 'End Date',
                selectedDate: endDate.value,
                onDateSelected: (date) => endDate.value = date,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: maxStudentsController,
                labelText: 'Maximum Number of Students',
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter the maximum number of students'
                    : null,
                theme: theme,
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: handleCreateClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CREATE CLASS',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement navigation to available classes list
                  },
                  child: Text(
                    'List of currently available classes',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.primary),
      decoration: InputDecoration(
        labelText: labelText,
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
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        errorStyle: TextStyle(color: theme.colorScheme.error),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String labelText,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
    required String? Function(String?)? validator,
    required ThemeData theme,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(color: theme.colorScheme.primary),
      decoration: InputDecoration(
        labelText: labelText,
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
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        errorStyle: TextStyle(color: theme.colorScheme.error),
      ),
      dropdownColor: theme.colorScheme.onPrimary,
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _DatePickerField extends HookWidget {
  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ThemeData theme;

  const _DatePickerField({
    required this.labelText,
    required this.selectedDate,
    required this.onDateSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(
      text: selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
          : '',
    );

    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.primary),
      decoration: InputDecoration(
        labelText: labelText,
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
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        errorStyle: TextStyle(color: theme.colorScheme.error),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
              controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
            }
          },
        ),
      ),
      readOnly: true,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please select a date' : null,
    );
  }
}
