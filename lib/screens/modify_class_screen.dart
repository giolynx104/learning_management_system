import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/models/class_model.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class ModifyClassScreen extends HookConsumerWidget {
  final String classId;
  
  const ModifyClassScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ModifyClassScreen - Received ClassId: $classId, Type: ${classId.runtimeType}');
    
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final classData = useState<ClassModel?>(null);

    // Load class data when screen opens
    useEffect(() {
      Future<void> loadClassData() async {
        try {
          isLoading.value = true;
          final authState = await ref.read(authProvider.future);
          if (authState == null) {
            throw Exception('Not authenticated');
          }

          debugPrint('ModifyClassScreen - Fetching data for ClassId: $classId');
          final response = await ref.read(classServiceProvider.notifier).getClassInfo(
            token: authState.token,
            classId: classId,
          );
          
          debugPrint('ModifyClassScreen - Received response: ${response.toString()}');
          classData.value = response;
        } catch (e) {
          debugPrint('ModifyClassScreen - Error: $e');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          // Navigate back if we can't load the class data
          context.pop();
        } finally {
          if (context.mounted) {
            isLoading.value = false;
          }
        }
      }

      loadClassData();
      return null;
    }, []);

    // Show loading indicator while fetching data
    if (classData.value == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final classNameController = useTextEditingController(text: classData.value!.className);
    final status = useState<String>(classData.value!.status);
    final startDate = useState<DateTime>(DateTime.parse(classData.value!.startDate));
    final endDate = useState<DateTime>(DateTime.parse(classData.value!.endDate));

    Future<void> handleEditClass() async {
      if (formKey.currentState?.validate() ?? false) {
        try {
          isLoading.value = true;
          final classService = ref.read(classServiceProvider.notifier);
          final authState = await ref.read(authProvider.future);
          
          if (authState == null) {
            throw Exception('Not authenticated');
          }

          await classService.editClass(
            token: authState.token,
            classId: classId,
            className: classNameController.text,
            status: status.value,
            startDate: startDate.value!,
            endDate: endDate.value!,
          );

          if (!context.mounted) return;
          context.pop(true); // Return true to indicate successful edit
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Class updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating class: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          isLoading.value = false;
        }
      }
    }

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
              Text('Class Code: ${classData.value!.classId}', 
                style: TextStyle(
                  fontSize: 18.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: classNameController,
                labelText: 'Class Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a class name' : null,
                theme: theme,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                value: status.value,
                labelText: 'Status',
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                  DropdownMenuItem(value: 'UPCOMING', child: Text('Upcoming')),
                ],
                onChanged: (value) => status.value = value ?? status.value,
                validator: (value) =>
                    value == null ? 'Please select a status' : null,
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
                onPressed: isLoading.value ? null : handleEditClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Changes',
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
