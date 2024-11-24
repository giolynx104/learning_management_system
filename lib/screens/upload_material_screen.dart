import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/providers/material_provider.dart';

class MaterialData {
  final String name;
  final int size;
  final String? path;
  String title;
  String description;
  String materialType;

  MaterialData({
    required this.name,
    required this.size,
    this.path,
    this.title = '',
    this.description = '',
    this.materialType = 'PDF',
  });

  MaterialData copyWith({
    String? title,
    String? description,
    String? materialType,
  }) {
    return MaterialData(
      name: name,
      size: size,
      path: path,
      title: title ?? this.title,
      description: description ?? this.description,
      materialType: materialType ?? this.materialType,
    );
  }
}

class UploadMaterialScreen extends HookConsumerWidget {
  final String classId;
  static const materialTypes = ['PDF', 'DOC', 'PPT', 'XLS', 'OTHER'];

  const UploadMaterialScreen({
    required this.classId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMaterials = useState<List<MaterialData>>([]);

    Future<void> selectMaterials() async {
      debugPrint('UploadMaterialScreen - Starting file selection');
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'],
        );
        
        debugPrint('UploadMaterialScreen - FilePicker result: ${result?.files.length} files selected');
        
        if (result != null) {
          // Check file sizes
          final invalidFiles = result.files.where(
            (file) => file.size > 50 * 1024 * 1024, // 50MB limit
          ).toList();
          
          debugPrint('UploadMaterialScreen - Invalid files: ${invalidFiles.length}');
          
          if (invalidFiles.isNotEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Files exceeding 50MB were skipped: ${invalidFiles.map((f) => f.name).join(", ")}',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
          
          // Filter out invalid files
          final validFiles = result.files.where(
            (file) => file.size <= 50 * 1024 * 1024,
          );
          
          debugPrint('UploadMaterialScreen - Valid files: ${validFiles.length}');
          
          selectedMaterials.value = [
            ...selectedMaterials.value,
            ...validFiles.map(
              (file) => MaterialData(
                name: file.name,
                size: file.size,
                path: file.path,
                title: file.name.split('.').first,
              ),
            ),
          ];
          
          debugPrint('UploadMaterialScreen - Total selected materials: ${selectedMaterials.value.length}');
        }
      } catch (e) {
        debugPrint('UploadMaterialScreen - Error selecting files: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error selecting files: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }

    void removeMaterial(int index) {
      final newMaterials = [...selectedMaterials.value];
      newMaterials.removeAt(index);
      selectedMaterials.value = newMaterials;
    }

    Future<void> uploadMaterials() async {
      debugPrint('UploadMaterialScreen - Starting upload for ${selectedMaterials.value.length} materials');
      try {
        for (var material in selectedMaterials.value) {
          if (material.path == null) {
            debugPrint('UploadMaterialScreen - Skipping material with null path: ${material.name}');
            continue;
          }
          
          debugPrint('UploadMaterialScreen - Uploading material: ${material.name}');
          final params = UploadMaterialParams(
            classId: classId,
            title: material.title,
            description: material.description,
            materialType: material.materialType,
            filePath: material.path!,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uploading ${material.name}...'),
                duration: const Duration(seconds: 1),
              ),
            );
          }

          await ref.read(uploadMaterialProvider(params).future);
          debugPrint('UploadMaterialScreen - Successfully uploaded: ${material.name}');
        }
        
        debugPrint('UploadMaterialScreen - All materials uploaded successfully');
        
        // Invalidate the material list to trigger a refresh
        ref.invalidate(materialListProvider(classId));
        ref.invalidate(materialListNotifierProvider(classId));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Materials uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Pop and refresh the material list screen
          context.pop(true); // Pass true to indicate successful upload
        }
      } catch (e) {
        debugPrint('UploadMaterialScreen - Error uploading materials: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Upload failed: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: e.toString()),
                  ],
                ),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Materials'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: selectMaterials,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Choose Materials'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedMaterials.value.isEmpty ? null : uploadMaterials,
                    child: const Text('Upload'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedMaterials.value.isEmpty
                  ? const Center(
                      child: Text('No materials selected.'),
                    )
                  : ListView.builder(
                      itemCount: selectedMaterials.value.length,
                      itemBuilder: (context, index) {
                        var material = selectedMaterials.value[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(
                              Icons.insert_drive_file,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(material.title.isEmpty 
                                  ? material.name 
                                  : material.title),
                                if (material.description.isNotEmpty)
                                  Text(
                                    material.description,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${(material.size / 1024).toStringAsFixed(2)} MB • ${material.materialType}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () => _showEditDialog(
                                    context,
                                    material,
                                    (updatedMaterial) {
                                      final newMaterials = [...selectedMaterials.value];
                                      newMaterials[index] = updatedMaterial;
                                      selectedMaterials.value = newMaterials;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () => removeMaterial(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate stateful widget for the edit dialog
class _EditMaterialDialog extends HookWidget {
  final MaterialData material;
  final ValueChanged<MaterialData> onSave;

  const _EditMaterialDialog({
    required this.material,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController(text: material.title);
    final descriptionController = useTextEditingController(text: material.description);
    final selectedType = useState(material.materialType);

    return AlertDialog(
      title: const Text('Edit Material Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter material title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter material description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType.value,
              decoration: const InputDecoration(
                labelText: 'Material Type',
              ),
              items: UploadMaterialScreen.materialTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedType.value = value;
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedMaterial = material.copyWith(
              title: titleController.text,
              description: descriptionController.text,
              materialType: selectedType.value,
            );
            onSave(updatedMaterial);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

Future<void> _showEditDialog(
  BuildContext context,
  MaterialData material,
  ValueChanged<MaterialData> onSave,
) async {
  await showDialog(
    context: context,
    builder: (context) => _EditMaterialDialog(
      material: material,
      onSave: onSave,
    ),
  );
} 