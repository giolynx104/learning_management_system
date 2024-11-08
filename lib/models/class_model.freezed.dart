// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) {
  return _ClassModel.fromJson(json);
}

/// @nodoc
mixin _$ClassModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_name')
  String get className => throw _privateConstructorUsedError;
  String? get schedule => throw _privateConstructorUsedError;
  @JsonKey(name: 'lecturer_id')
  int get lecturerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_student_amount')
  int get maxStudentAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'attached_code')
  String? get attachedCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_type')
  String get classType => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String get endDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this ClassModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassModelCopyWith<ClassModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassModelCopyWith<$Res> {
  factory $ClassModelCopyWith(
          ClassModel value, $Res Function(ClassModel) then) =
      _$ClassModelCopyWithImpl<$Res, ClassModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'class_id') String classId,
      @JsonKey(name: 'class_name') String className,
      String? schedule,
      @JsonKey(name: 'lecturer_id') int lecturerId,
      @JsonKey(name: 'max_student_amount') int maxStudentAmount,
      @JsonKey(name: 'attached_code') String? attachedCode,
      @JsonKey(name: 'class_type') String classType,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      String status});
}

/// @nodoc
class _$ClassModelCopyWithImpl<$Res, $Val extends ClassModel>
    implements $ClassModelCopyWith<$Res> {
  _$ClassModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classId = null,
    Object? className = null,
    Object? schedule = freezed,
    Object? lecturerId = null,
    Object? maxStudentAmount = null,
    Object? attachedCode = freezed,
    Object? classType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      classId: null == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String,
      className: null == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as String?,
      lecturerId: null == lecturerId
          ? _value.lecturerId
          : lecturerId // ignore: cast_nullable_to_non_nullable
              as int,
      maxStudentAmount: null == maxStudentAmount
          ? _value.maxStudentAmount
          : maxStudentAmount // ignore: cast_nullable_to_non_nullable
              as int,
      attachedCode: freezed == attachedCode
          ? _value.attachedCode
          : attachedCode // ignore: cast_nullable_to_non_nullable
              as String?,
      classType: null == classType
          ? _value.classType
          : classType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassModelImplCopyWith<$Res>
    implements $ClassModelCopyWith<$Res> {
  factory _$$ClassModelImplCopyWith(
          _$ClassModelImpl value, $Res Function(_$ClassModelImpl) then) =
      __$$ClassModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'class_id') String classId,
      @JsonKey(name: 'class_name') String className,
      String? schedule,
      @JsonKey(name: 'lecturer_id') int lecturerId,
      @JsonKey(name: 'max_student_amount') int maxStudentAmount,
      @JsonKey(name: 'attached_code') String? attachedCode,
      @JsonKey(name: 'class_type') String classType,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      String status});
}

/// @nodoc
class __$$ClassModelImplCopyWithImpl<$Res>
    extends _$ClassModelCopyWithImpl<$Res, _$ClassModelImpl>
    implements _$$ClassModelImplCopyWith<$Res> {
  __$$ClassModelImplCopyWithImpl(
      _$ClassModelImpl _value, $Res Function(_$ClassModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? classId = null,
    Object? className = null,
    Object? schedule = freezed,
    Object? lecturerId = null,
    Object? maxStudentAmount = null,
    Object? attachedCode = freezed,
    Object? classType = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(_$ClassModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      classId: null == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String,
      className: null == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: freezed == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as String?,
      lecturerId: null == lecturerId
          ? _value.lecturerId
          : lecturerId // ignore: cast_nullable_to_non_nullable
              as int,
      maxStudentAmount: null == maxStudentAmount
          ? _value.maxStudentAmount
          : maxStudentAmount // ignore: cast_nullable_to_non_nullable
              as int,
      attachedCode: freezed == attachedCode
          ? _value.attachedCode
          : attachedCode // ignore: cast_nullable_to_non_nullable
              as String?,
      classType: null == classType
          ? _value.classType
          : classType // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassModelImpl implements _ClassModel {
  const _$ClassModelImpl(
      {required this.id,
      @JsonKey(name: 'class_id') required this.classId,
      @JsonKey(name: 'class_name') required this.className,
      this.schedule,
      @JsonKey(name: 'lecturer_id') required this.lecturerId,
      @JsonKey(name: 'max_student_amount') required this.maxStudentAmount,
      @JsonKey(name: 'attached_code') this.attachedCode,
      @JsonKey(name: 'class_type') required this.classType,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      required this.status});

  factory _$ClassModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  @JsonKey(name: 'class_name')
  final String className;
  @override
  final String? schedule;
  @override
  @JsonKey(name: 'lecturer_id')
  final int lecturerId;
  @override
  @JsonKey(name: 'max_student_amount')
  final int maxStudentAmount;
  @override
  @JsonKey(name: 'attached_code')
  final String? attachedCode;
  @override
  @JsonKey(name: 'class_type')
  final String classType;
  @override
  @JsonKey(name: 'start_date')
  final String startDate;
  @override
  @JsonKey(name: 'end_date')
  final String endDate;
  @override
  final String status;

  @override
  String toString() {
    return 'ClassModel(id: $id, classId: $classId, className: $className, schedule: $schedule, lecturerId: $lecturerId, maxStudentAmount: $maxStudentAmount, attachedCode: $attachedCode, classType: $classType, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.lecturerId, lecturerId) ||
                other.lecturerId == lecturerId) &&
            (identical(other.maxStudentAmount, maxStudentAmount) ||
                other.maxStudentAmount == maxStudentAmount) &&
            (identical(other.attachedCode, attachedCode) ||
                other.attachedCode == attachedCode) &&
            (identical(other.classType, classType) ||
                other.classType == classType) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      classId,
      className,
      schedule,
      lecturerId,
      maxStudentAmount,
      attachedCode,
      classType,
      startDate,
      endDate,
      status);

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassModelImplCopyWith<_$ClassModelImpl> get copyWith =>
      __$$ClassModelImplCopyWithImpl<_$ClassModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassModelImplToJson(
      this,
    );
  }
}

abstract class _ClassModel implements ClassModel {
  const factory _ClassModel(
      {required final int id,
      @JsonKey(name: 'class_id') required final String classId,
      @JsonKey(name: 'class_name') required final String className,
      final String? schedule,
      @JsonKey(name: 'lecturer_id') required final int lecturerId,
      @JsonKey(name: 'max_student_amount') required final int maxStudentAmount,
      @JsonKey(name: 'attached_code') final String? attachedCode,
      @JsonKey(name: 'class_type') required final String classType,
      @JsonKey(name: 'start_date') required final String startDate,
      @JsonKey(name: 'end_date') required final String endDate,
      required final String status}) = _$ClassModelImpl;

  factory _ClassModel.fromJson(Map<String, dynamic> json) =
      _$ClassModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  @JsonKey(name: 'class_name')
  String get className;
  @override
  String? get schedule;
  @override
  @JsonKey(name: 'lecturer_id')
  int get lecturerId;
  @override
  @JsonKey(name: 'max_student_amount')
  int get maxStudentAmount;
  @override
  @JsonKey(name: 'attached_code')
  String? get attachedCode;
  @override
  @JsonKey(name: 'class_type')
  String get classType;
  @override
  @JsonKey(name: 'start_date')
  String get startDate;
  @override
  @JsonKey(name: 'end_date')
  String get endDate;
  @override
  String get status;

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassModelImplCopyWith<_$ClassModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
