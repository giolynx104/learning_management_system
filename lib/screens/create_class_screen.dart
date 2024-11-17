import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

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

    /// Status is set to 'ACTIVE' by default in the backend
    /// This is handled server-side and doesn't need to be sent
    /// in the create class request

    Future<void> handleCreateClass() async {
      if (formKey.currentState?.validate() ?? false) {
        try {
          final classService = ref.read(classServiceProvider.notifier);
          final authState = await ref.read(authProvider.future);
          
          if (authState == null) {
            throw Exception('Not authenticated');
          }
          
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
            // Status is handled server-side and defaults to 'ACTIVE'
          );

          if (!context.mounted) return;
          context.pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Class created successfully (Status: Active)',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating class: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create New Class',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a class code';
                  }
                  if (value.length != 6) {
                    return 'Class code must be exactly 6 digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Class code must contain only digits';
                  }
                  return null;
                },
                maxLength: 6,
                keyboardType: TextInputType.number,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: associatedClassCodeController,
                labelText: 'Associated Class Code (Optional)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  if (value.length != 6) {
                    return 'Associated class code must be exactly 6 digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Associated class code must contain only digits';
                  }
                  return null;
                },
                maxLength: 6,
                keyboardType: TextInputType.number,
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
              _buildDropdownField(
                value: classType.value,
                labelText: 'Class Type',
                items: const [
                  DropdownMenuItem(value: 'Theory', child: Text('Theory')),
                  DropdownMenuItem(value: 'Exercise', child: Text('Exercise')),
                  DropdownMenuItem(value: 'Both', child: Text('Both')),
                ],
                onChanged: (value) => classType.value = value as String?,
                validator: (value) =>
                    value == null ? 'Please select a class type' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: maxStudentsController,
                labelText: 'Maximum Students',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum number of students';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: handleCreateClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create Class',
                  style: TextStyle(fontSize: 18.0),
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
    required FormFieldValidator<String> validator,
    required ThemeData theme,
    TextInputType? keyboardType,
    int? maxLength,
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
        counterText: '',
      ),
      maxLength: maxLength,
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
