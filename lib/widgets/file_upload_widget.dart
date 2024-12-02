import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadConfig {
  final List<String> allowedExtensions;
  final int maxSizeInBytes;
  final bool allowMultiple;
  final String? helperText;

  const FileUploadConfig({
    required this.allowedExtensions,
    required this.maxSizeInBytes,
    this.allowMultiple = false,
    this.helperText,
  });

  String get maxSizeInMB => (maxSizeInBytes / (1024 * 1024)).toStringAsFixed(0);
}

class FileUploadWidget extends StatelessWidget {
  final FileUploadConfig config;
  final List<PlatformFile> selectedFiles;
  final bool isLoading;
  final Function(List<PlatformFile>) onFilesSelected;
  final Function(int)? onFileRemoved;
  final String? buttonLabel;

  const FileUploadWidget({
    super.key,
    required this.config,
    required this.selectedFiles,
    required this.isLoading,
    required this.onFilesSelected,
    this.onFileRemoved,
    this.buttonLabel,
  });

  String? _getFileError(PlatformFile file) {
    // Check file size
    if (file.size > config.maxSizeInBytes) {
      return 'File size must be less than ${config.maxSizeInMB}MB';
    }

    // Check file extension
    final extension = file.extension?.toLowerCase();
    if (extension == null || !config.allowedExtensions.contains(extension)) {
      return 'Invalid file type. Allowed types: ${config.allowedExtensions.join(", ")}';
    }

    // Check file name length
    if (file.name.length > 255) {
      return 'File name is too long';
    }

    // Check for malicious file names
    if (file.name.contains('..') || 
        file.name.contains('/') || 
        file.name.contains('\\')) {
      return 'Invalid file name';
    }

    return null;
  }

  String _sanitizeFileName(String fileName) {
    // Remove special characters and spaces
    final sanitized = fileName
        .replaceAll(RegExp(r'[^\w\s\-\.]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    
    // Ensure the filename isn't too long
    const maxLength = 100;
    if (sanitized.length > maxLength) {
      final extension = sanitized.split('.').last;
      return '${sanitized.substring(0, maxLength - extension.length - 1)}.$extension';
    }
    
    return sanitized;
  }

  Future<void> _pickFiles(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: config.allowedExtensions,
        allowMultiple: config.allowMultiple,
        withData: true,
        onFileLoading: (FilePickerStatus status) => debugPrint(status.toString()),
      );

      if (result != null) {
        final validFiles = <PlatformFile>[];
        final errors = <String>[];

        for (final file in result.files) {
          final error = _getFileError(file);
          if (error != null) {
            errors.add('${file.name}: $error');
            continue;
          }

          final sanitizedName = _sanitizeFileName(file.name);
          debugPrint('Original filename: ${file.name}');
          debugPrint('Sanitized filename: $sanitizedName');
          
          validFiles.add(file);
        }

        if (errors.isNotEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errors.join('\n')),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }

        if (validFiles.isNotEmpty) {
          onFilesSelected(validFiles);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment${config.allowMultiple ? 's' : ''} ${config.helperText ?? '(Optional)'}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Allowed file types: ${config.allowedExtensions.join(", ")}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(
          'Maximum file size: ${config.maxSizeInMB}MB',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : () => _pickFiles(context),
                icon: const Icon(Icons.attach_file),
                label: Text(buttonLabel ?? 'Choose File${config.allowMultiple ? 's' : ''}'),
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
        ),
        if (selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      file.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${(file.size / 1024).toStringAsFixed(1)}KB',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (onFileRemoved != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: isLoading ? null : () => onFileRemoved!(index),
                      tooltip: 'Remove file',
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
} 