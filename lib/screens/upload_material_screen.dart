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

  MaterialData({required this.name, required this.size, this.path});
}

class UploadMaterialScreen extends HookConsumerWidget {
  final String classId;

  const UploadMaterialScreen({
    required this.classId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMaterials = useState<List<MaterialData>>([]);

    useEffect(() {
      debugPrint('UploadMaterialScreen - ClassId: $classId');
      return null;
    }, []);

    final materialListState = ref.watch(materialListProvider(classId));

    useEffect(() {
      materialListState.whenData((response) {
        debugPrint('Material List Response: $response');
      });
      return null;
    }, [materialListState]);

    Future<void> selectMaterials() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result != null) {
        selectedMaterials.value = [
          ...selectedMaterials.value,
          ...result.files.map(
            (file) => MaterialData(
              name: file.name,
              size: file.size,
              path: file.path,
            ),
          ),
        ];
      }
    }

    void removeMaterial(int index) {
      final newMaterials = [...selectedMaterials.value];
      newMaterials.removeAt(index);
      selectedMaterials.value = newMaterials;
    }

    Future<void> editMaterialName(int index) async {
      String currentName = selectedMaterials.value[index].name;
      TextEditingController controller = TextEditingController(text: currentName);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Material Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newMaterials = [...selectedMaterials.value];
                newMaterials[index] = MaterialData(
                  name: controller.text,
                  size: selectedMaterials.value[index].size,
                  path: selectedMaterials.value[index].path,
                );
                selectedMaterials.value = newMaterials;
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    Future<void> uploadMaterials() async {
      try {
        for (var material in selectedMaterials.value) {
          if (material.path == null) continue;
          
          final params = UploadMaterialParams(
            classId: classId,
            title: material.name,
            description: 'Uploaded from mobile app',
            materialType: 'document',
            filePath: material.path!,
          );

          await ref.read(uploadMaterialProvider(params).future);
        }
        
        ref.invalidate(materialListProvider(classId));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Materials uploaded successfully')),
          );
        }
      } catch (e) {
        debugPrint('Error uploading materials: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading materials: $e')),
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
                            title: Text(material.name),
                            subtitle: Text(
                              '${(material.size / 1024).toStringAsFixed(2)} MB',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () => editMaterialName(index),
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