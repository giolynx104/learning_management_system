import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/models/material_model.dart';
import 'package:learning_management_system/providers/material_provider.dart';
import 'package:learning_management_system/widgets/file_upload_widget.dart';
import 'package:learning_management_system/constants/file_upload_configs.dart';

class EditMaterialScreen extends HookConsumerWidget {
  final MaterialModel material;
  static const materialTypes = ['PDF', 'DOC', 'PPT', 'XLS', 'IMAGE', 'OTHER'];

  const EditMaterialScreen({
    required this.material,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: material.materialName);
    final descriptionController = useTextEditingController(
      text: material.description,
    );
    final selectedFile = useState<String?>(null);
    final selectedType = useState(material.materialType);
    final isLoading = useState(false);

    // Check if any changes were made
    bool hasChanges() {
      return titleController.text != material.materialName ||
          descriptionController.text != material.description ||
          selectedType.value != material.materialType ||
          selectedFile.value != null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Material'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current file info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current File',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _getMaterialIcon(material.materialType),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    material.materialName,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  if (material.materialLink != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'File already uploaded',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // New file selection (optional)
                if (selectedFile.value == null)
                  OutlinedButton.icon(
                    onPressed: isLoading.value
                        ? null
                        : () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.any,
                              allowMultiple: false,
                            );
                            if (result != null) {
                              selectedFile.value = result.files.single.path;
                            }
                          },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Select New File (Optional)'),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'New File Selected',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selectedFile.value!.split('/').last,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => selectedFile.value = null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Material details form
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Material Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedType.value,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items: materialTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: selectedFile.value == null
                              ? (value) {
                                  if (value != null) {
                                    selectedType.value = value;
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: isLoading.value || !hasChanges()
                ? null
                : () async {
                    try {
                      isLoading.value = true;

                      // If no file is selected and only metadata changed, show error
                      if (selectedFile.value == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a file to update the material'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      await ref
                          .read(materialListNotifierProvider(material.classId).notifier)
                          .editMaterial(
                            materialId: material.id,
                            classId: material.classId,
                            title: titleController.text,
                            description: descriptionController.text,
                            materialType: selectedType.value,
                            filePath: selectedFile.value,
                          );
                      
                      if (context.mounted) {
                        context.pop(true); // Pop with success result
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update material: $e'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    } finally {
                      isLoading.value = false;
                    }
                  },
            child: isLoading.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(hasChanges() ? 'Save Changes' : 'No Changes'),
          ),
        ),
      ),
    );
  }

  IconData _getMaterialIcon(String materialType) {
    switch (materialType.toLowerCase()) {
      case 'document':
        return Icons.description;
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_library;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.file_present;
    }
  }
} 