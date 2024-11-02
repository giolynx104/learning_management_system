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
  String get classId => throw _privateConstructorUsedError;
  String get className => throw _privateConstructorUsedError;
  String? get schedule => throw _privateConstructorUsedError;
  int get lecturerId => throw _privateConstructorUsedError;
  int get maxStudentAmount => throw _privateConstructorUsedError;
  String? get attachedCode => throw _privateConstructorUsedError;
  String get classType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get endDate => throw _privateConstructorUsedError;
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
      String classId,
      String className,
      String? schedule,
      int lecturerId,
      int maxStudentAmount,
      String? attachedCode,
      String classType,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) DateTime startDate,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) DateTime endDate,
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
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      String classId,
      String className,
      String? schedule,
      int lecturerId,
      int maxStudentAmount,
      String? attachedCode,
      String classType,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) DateTime startDate,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) DateTime endDate,
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
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      required this.classId,
      required this.className,
      this.schedule,
      required this.lecturerId,
      required this.maxStudentAmount,
      this.attachedCode,
      required this.classType,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      required this.startDate,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      required this.endDate,
      required this.status});

  factory _$ClassModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassModelImplFromJson(json);

  @override
  final int id;
  @override
  final String classId;
  @override
  final String className;
  @override
  final String? schedule;
  @override
  final int lecturerId;
  @override
  final int maxStudentAmount;
  @override
  final String? attachedCode;
  @override
  final String classType;
  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime startDate;
  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime endDate;
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
      required final String classId,
      required final String className,
      final String? schedule,
      required final int lecturerId,
      required final int maxStudentAmount,
      final String? attachedCode,
      required final String classType,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      required final DateTime startDate,
      @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
      required final DateTime endDate,
      required final String status}) = _$ClassModelImpl;

  factory _ClassModel.fromJson(Map<String, dynamic> json) =
      _$ClassModelImpl.fromJson;

  @override
  int get id;
  @override
  String get classId;
  @override
  String get className;
  @override
  String? get schedule;
  @override
  int get lecturerId;
  @override
  int get maxStudentAmount;
  @override
  String? get attachedCode;
  @override
  String get classType;
  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get startDate;
  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get endDate;
  @override
  String get status;

  /// Create a copy of ClassModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassModelImplCopyWith<_$ClassModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
