import 'package:learning_management_system/widgets/file_upload_widget.dart';

class FileUploadConfigs {
  static const assignment = FileUploadConfig(
    allowedExtensions: [
      'pdf', 'doc', 'docx', 'txt', 'rtf',
      'png', 'jpg', 'jpeg',
      'xlsx', 'xls',
      'zip', 'rar'
    ],
    maxSizeInBytes: 10 * 1024 * 1024, // 10MB
    allowMultiple: false,
  );

  static const material = FileUploadConfig(
    allowedExtensions: [
      'pdf', 'doc', 'docx', 'ppt', 'pptx',
      'xls', 'xlsx',
      'png', 'jpg', 'jpeg',
    ],
    maxSizeInBytes: 50 * 1024 * 1024, // 50MB
    allowMultiple: true,
    helperText: 'Required',
  );

  static const absenceRequest = FileUploadConfig(
    allowedExtensions: [
      'pdf', 'png', 'jpg', 'jpeg',
    ],
    maxSizeInBytes: 5 * 1024 * 1024, // 5MB
    allowMultiple: false,
    helperText: 'Required',
  );

  static const chat = FileUploadConfig(
    allowedExtensions: [
      'png', 'jpg', 'jpeg', 'gif',
    ],
    maxSizeInBytes: 2 * 1024 * 1024, // 2MB
    allowMultiple: false,
  );
} 