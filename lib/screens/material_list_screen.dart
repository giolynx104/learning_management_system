import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/providers/material_provider.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/models/material_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learning_management_system/providers/auth_provider.dart';

class MaterialListScreen extends HookConsumerWidget {
  final String classId;

  const MaterialListScreen({
    required this.classId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldRefresh = useState(false);
    final materialListState = ref.watch(materialListProvider(classId));
    final authState = ref.watch(authProvider);
    final isStudent = authState.value?.role.toLowerCase() == 'student';

    useEffect(() {
      if (shouldRefresh.value) {
        debugPrint('MaterialListScreen - Refreshing material list');
        ref.invalidate(materialListProvider(classId));
        ref.invalidate(materialListNotifierProvider(classId));
        shouldRefresh.value = false;
      }
      return null;
    }, [shouldRefresh.value]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Materials'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              shouldRefresh.value = true;
            },
          ),
        ],
      ),
      body: materialListState.when(
        data: (response) {
          if (response.data.isEmpty) {
            return const _EmptyMaterialList();
          }

          return isStudent 
              ? _StudentMaterialListView(materials: response.data)
              : _TeacherMaterialListView(materials: response.data);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: SelectableText.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Error loading materials\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: error.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: !isStudent ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>(Routes.getUploadMaterialPath(classId));
          if (result == true) {
            debugPrint('MaterialListScreen - Upload successful, refreshing list');
            ref.invalidate(materialListProvider(classId));
            await ref.read(materialListProvider(classId).future);
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Material uploaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Material'),
      ) : null,
    );
  }
}

class _EmptyMaterialList extends StatelessWidget {
  const _EmptyMaterialList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No materials available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload materials using the button below',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _StudentMaterialListView extends StatelessWidget {
  final List<MaterialModel> materials;

  const _StudentMaterialListView({required this.materials});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and type
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMaterialIcon(material.materialType),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      material.materialType.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.materialName,
                      style: theme.textTheme.titleLarge,
                    ),
                    if (material.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        material.description!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // Material details
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _DetailChip(
                          icon: Icons.description,
                          label: material.materialType,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              if (material.materialLink != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FilledButton.icon(
                    onPressed: () {
                      // TODO: Implement download functionality
                      debugPrint('Download material: ${material.materialLink}');
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Material'),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherMaterialListView extends HookConsumerWidget {
  final List<MaterialModel> materials;

  const _TeacherMaterialListView({required this.materials});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getMaterialIcon(material.materialType),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              material.materialName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: material.description != null 
                ? Text(
                    material.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (material.materialLink != null)
                  IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Download material',
                    onPressed: () {
                      // TODO: Implement download functionality
                      debugPrint('Download material: ${material.materialLink}');
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit material',
                  onPressed: () => _showEditMaterialSheet(
                    context,
                    ref,
                    material,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete material',
                  onPressed: () => _showDeleteConfirmation(
                    context,
                    ref,
                    material,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    MaterialModel material,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text(
          'Are you sure you want to delete "${material.materialName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(materialListNotifierProvider(material.classId).notifier)
            .deleteMaterial(material.id);
        
        ref.invalidate(materialListProvider(material.classId));
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete material: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditMaterialSheet(
    BuildContext context,
    WidgetRef ref,
    MaterialModel material,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditMaterialSheet(material: material),
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

class _EditMaterialSheet extends HookConsumerWidget {
  final MaterialModel material;

  const _EditMaterialSheet({required this.material});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: material.materialName);
    final descriptionController = useTextEditingController(
      text: material.description,
    );
    final selectedFile = useState<String?>(null);
    final isLoading = useState(false);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Material',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: isLoading.value
                ? null
                : () async {
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      selectedFile.value = result.files.single.path;
                    }
                  },
            icon: const Icon(Icons.attach_file),
            label: Text(
              selectedFile.value != null
                  ? 'Change File'
                  : 'Select New File (Optional)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading.value
                ? null
                : () async {
                    try {
                      isLoading.value = true;
                      await ref
                          .read(materialListNotifierProvider(material.classId).notifier)
                          .editMaterial(
                            materialId: material.id,
                            classId: material.classId,
                            title: titleController.text,
                            description: descriptionController.text,
                            materialType: material.materialType,
                            filePath: selectedFile.value,
                          );
                      
                      ref.invalidate(materialListProvider(material.classId));
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Material updated successfully'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update material: $e'),
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
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
                : const Text('Save Changes'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 