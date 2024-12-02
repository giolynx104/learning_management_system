import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:learning_management_system/services/class_service.dart';
import 'package:learning_management_system/models/class_model.dart';

part 'class_provider.g.dart';

@riverpod
class ClassProvider extends _$ClassProvider {
  @override
  FutureOr<void> build() {}

  ClassService get _classService => ref.read(classServiceProvider.notifier);

  Future<ClassModel?> getClassInfo({
    required String token,
    required String classId,
  }) async {
    return await _classService.getClassInfo(
      token: token,
      classId: classId,
    );
  }
} 