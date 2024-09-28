import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ModifyClassScreen extends HookConsumerWidget {
  const ModifyClassScreen({super.key});

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

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text('Modify Class', style: TextStyle(color: theme.colorScheme.onPrimary)),
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
                'Modify Class Information',
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showConfirmationDialog(
                          context,
                          'Delete Class',
                          'Are you sure you want to delete this class?',
                          () {
                            // TODO: Implement class deletion logic
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete class',
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          _showConfirmationDialog(
                            context,
                            'Confirm Modification',
                            'Are you sure you want to modify this class?',
                            () {
                              // TODO: Implement class modification logic
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm modification',
                        style: TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
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

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: onConfirm,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
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
