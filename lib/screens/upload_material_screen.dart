import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/providers/material_provider.dart';
import 'package:learning_management_system/widgets/file_upload_widget.dart';
import 'package:learning_management_system/constants/file_upload_configs.dart';
import 'package:learning_management_system/services/material_service.dart';

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
    required this.materialType,
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

  static String detectMaterialType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => 'PDF',
      'doc' || 'docx' => 'DOC',
      'ppt' || 'pptx' => 'PPT',
      'xls' || 'xlsx' => 'XLS',
      'jpg' || 'jpeg' || 'png' => 'IMAGE',
      _ => 'OTHER',
    };
  }
}

class UploadMaterialScreen extends HookConsumerWidget {
  final String classId;
  static const materialTypes = ['PDF', 'DOC', 'PPT', 'XLS', 'IMAGE', 'OTHER'];

  const UploadMaterialScreen({
    required this.classId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMaterials = useState<List<MaterialData>>([]);
    final isLoading = useState(false);

    Future<void> uploadMaterials() async {
      if (selectedMaterials.value.isEmpty) return;

      isLoading.value = true;
      try {
        for (var material in selectedMaterials.value) {
          if (material.path == null) {
            debugPrint('UploadMaterialScreen - Skipping material with null path: ${material.name}');
            continue;
          }
          
          debugPrint('UploadMaterialScreen - Uploading material: ${material.name}');
          
          await ref.read(materialServiceProvider.notifier).uploadMaterial(
            token: ref.read(authProvider).value!.token!,
            classId: classId,
            title: material.title,
            description: material.description,
            materialType: material.materialType,
            filePath: material.path!,
          );
          
          debugPrint('UploadMaterialScreen - Material uploaded successfully: ${material.name}');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Materials uploaded successfully')),
          );
          context.pop(true);
        }
      } catch (e) {
        debugPrint('UploadMaterialScreen - Error uploading materials: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading materials: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        isLoading.value = false;
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FileUploadWidget(
                  config: FileUploadConfigs.material,
                  selectedFiles: selectedMaterials.value.map((m) => 
                    PlatformFile(
                      name: m.name,
                      size: m.size,
                      path: m.path,
                    )
                  ).toList(),
                  isLoading: isLoading.value,
                  onFilesSelected: (files) {
                    selectedMaterials.value = [
                      ...selectedMaterials.value,
                      ...files.map(
                        (file) => MaterialData(
                          name: file.name,
                          size: file.size,
                          path: file.path,
                          title: file.name.split('.').first,
                          materialType: MaterialData.detectMaterialType(file.name),
                        ),
                      ),
                    ];
                  },
                  onFileRemoved: (index) {
                    final newMaterials = [...selectedMaterials.value];
                    newMaterials.removeAt(index);
                    selectedMaterials.value = newMaterials;
                  },
                  buttonLabel: 'Choose Materials',
                ),
                const SizedBox(height: 20),
                if (selectedMaterials.value.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No materials selected.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedMaterials.value.length,
                    itemBuilder: (context, index) {
                      var material = selectedMaterials.value[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                initialValue: material.title,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  final newMaterials = [...selectedMaterials.value];
                                  newMaterials[index] = material.copyWith(title: value);
                                  selectedMaterials.value = newMaterials;
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                initialValue: material.description,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                                onChanged: (value) {
                                  final newMaterials = [...selectedMaterials.value];
                                  newMaterials[index] = material.copyWith(description: value);
                                  selectedMaterials.value = newMaterials;
                                },
                              ),
                              const SizedBox(height: 8),
                              // Material type display
                              InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  material.materialType,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                if (selectedMaterials.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      top: 16.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
                    ),
                    child: FilledButton(
                      onPressed: isLoading.value ? null : uploadMaterials,
                      child: isLoading.value
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
                                Text('Uploading...'),
                              ],
                            )
                          : const Text('Upload Materials'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 