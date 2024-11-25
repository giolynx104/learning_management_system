import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learning_management_system/exceptions/api_exceptions.dart';
import 'package:learning_management_system/routes/routes.dart';
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
      debugPrint('CreateClassScreen - Starting class creation');
      if (formKey.currentState?.validate() ?? false) {
        try {
          final classService = ref.read(classServiceProvider.notifier);
          final authState = await ref.read(authProvider.future);
          
          debugPrint('CreateClassScreen - Auth state: ${authState?.token}');
          
          if (authState == null) {
            throw Exception('Not authenticated');
          }

          // Validate class code format
          if (!RegExp(r'^\d{6}$').hasMatch(classCodeController.text.trim())) {
            throw Exception('Class code must be exactly 6 digits');
          }

          // Validate dates
          if (startDate.value == null || endDate.value == null) {
            throw Exception('Please select both start and end dates');
          }

          if (endDate.value!.isBefore(startDate.value!)) {
            throw Exception('End date cannot be before start date');
          }

          // Validate max students
          final maxStudents = int.tryParse(maxStudentsController.text);
          if (maxStudents == null || maxStudents <= 0) {
            throw Exception('Please enter a valid number for maximum students');
          }

          final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate.value!);
          final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate.value!);

          debugPrint('CreateClassScreen - Request data:');
          debugPrint('Token: ${authState.token}');
          debugPrint('ClassId: ${classCodeController.text.trim()}');
          debugPrint('ClassName: ${classNameController.text.trim()}');
          debugPrint('ClassType: ${classType.value}');
          debugPrint('StartDate: $formattedStartDate');
          debugPrint('EndDate: $formattedEndDate');
          debugPrint('MaxStudents: $maxStudents');
          debugPrint('AttachedCode: ${associatedClassCodeController.text.isEmpty ? "null" : associatedClassCodeController.text.trim()}');

          await classService.createClass(
            token: authState.token ?? '',
            classId: classCodeController.text.trim(),
            className: classNameController.text.trim(),
            classType: classType.value!,
            startDate: formattedStartDate,
            endDate: formattedEndDate,
            maxStudentAmount: maxStudents,
            attachedCode: associatedClassCodeController.text.isEmpty 
                ? null 
                : associatedClassCodeController.text.trim(),
          );

          debugPrint('CreateClassScreen - Class created successfully');

          if (!context.mounted) return;
          
          // Pop and return true to indicate success
          context.pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Class created successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } on UnauthorizedException catch (e) {
          debugPrint('CreateClassScreen - UnauthorizedException: $e');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
          context.go(Routes.signin);
        } catch (e) {
          debugPrint('CreateClassScreen - Error: $e');
          if (!context.mounted) return;
          
          String errorMessage;
          if (e.toString().contains('Class ID already exists')) {
            errorMessage = 'This class code is already in use. Please try a different one.';
          } else if (e.toString().contains('maxStudentAmount')) {
            errorMessage = 'Maximum number of students must be between 1 and 50.';
          } else if (e.toString().contains('Invalid parameters')) {
            errorMessage = 'Invalid parameters. Please check all fields and try again.';
          } else if (e.toString().contains('parameter value is invalid')) {
            errorMessage = 'One or more fields have invalid values. Please check and try again.';
          } else {
            errorMessage = e.toString();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Class'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: theme.colorScheme.onPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: classCodeController,
                labelText: 'Class Code (6 digits)',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a class code';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'Class code must be exactly 6 digits';
                  }
                  return null;
                },
                maxLength: 6,
                keyboardType: TextInputType.number,
                theme: theme,
                helperText: 'Enter exactly 6 digits',
                suffixIcon: Tooltip(
                  message: 'Class code must be 6 digits',
                  child: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
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
                  DropdownMenuItem(value: 'Theory', child: Text('Theory (LT)')),
                  DropdownMenuItem(value: 'Exercise', child: Text('Exercise (BT)')),
                  DropdownMenuItem(value: 'Both', child: Text('Both (LT_BT)')),
                ],
                onChanged: (value) => classType.value = value,
                validator: (value) =>
                    value == null ? 'Please select a class type' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: maxStudentsController,
                labelText: 'Maximum Students (1-50)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum number of students';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid number';
                  }
                  if (number > 50) {
                    return 'Maximum students cannot exceed 50';
                  }
                  return null;
                },
                theme: theme,
                helperText: 'Enter a number between 1 and 50',
                suffixIcon: Tooltip(
                  message: 'Maximum allowed: 50 students',
                  child: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
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
    String? helperText,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
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
        helperText: helperText,
        helperStyle: TextStyle(color: theme.colorScheme.secondary),
        suffixIcon: suffixIcon,
        counterText: '',
      ),
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters ?? (keyboardType == TextInputType.number
          ? [
              FilteringTextInputFormatter.digitsOnly,
              if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
              if (labelText.contains('Maximum Students'))
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final number = int.tryParse(newValue.text);
                  if (number == null || number > 50) return oldValue;
                  return newValue;
                }),
            ]
          : null),
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
            FocusScope.of(context).unfocus();
            
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
