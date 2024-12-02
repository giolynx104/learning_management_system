import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/models/absence_request_model.dart';
import 'package:learning_management_system/providers/absence_request_provider.dart';
import 'package:learning_management_system/widgets/file_upload_widget.dart';
import 'package:learning_management_system/constants/file_upload_configs.dart';

class AbsenceRequestScreen extends HookConsumerWidget {
  final String classId;

  const AbsenceRequestScreen({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState<DateTime?>(null);
    final selectedFile = useState<PlatformFile?>(null);
    final titleController = useTextEditingController();
    final reasonController = useTextEditingController();
    final requestState = ref.watch(submitAbsenceRequestProvider);

    Future<void> pickDate() async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null) {
        selectedDate.value = pickedDate;
      }
    }

    Future<void> submit() async {
      if (selectedDate.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
        return;
      }

      if (selectedFile.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload a proof file')),
        );
        return;
      }

      final request = AbsenceRequest(
        classId: classId,
        title: titleController.text,
        reason: reasonController.text,
        date: DateFormat('yyyy-MM-dd').format(selectedDate.value!),
        proofFile: selectedFile.value!.path,
      );

      try {
        await ref.read(submitAbsenceRequestProvider.notifier).submit(request);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Absence request submitted successfully')),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting request: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Absence'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    selectedDate.value == null
                        ? 'Select Date'
                        : DateFormat('dd/MM/yyyy').format(selectedDate.value!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FileUploadWidget(
                config: FileUploadConfigs.absenceRequest,
                selectedFiles: selectedFile.value != null ? [selectedFile.value!] : [],
                isLoading: requestState.isLoading,
                onFilesSelected: (files) {
                  selectedFile.value = files.first;
                },
                onFileRemoved: (_) {
                  selectedFile.value = null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: requestState.isLoading ? null : submit,
                child: requestState.isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
