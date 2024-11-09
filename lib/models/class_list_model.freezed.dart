// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'class_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClassListItem _$ClassListItemFromJson(Map<String, dynamic> json) {
  return _ClassListItem.fromJson(json);
}

/// @nodoc
mixin _$ClassListItem {
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_name')
  String get className => throw _privateConstructorUsedError;
  @JsonKey(name: 'attached_code')
  String? get attachedCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_type')
  String get classType => throw _privateConstructorUsedError;
  @JsonKey(name: 'lecturer_name')
  String get lecturerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_count')
  int get studentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  String get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  String get endDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this ClassListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClassListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClassListItemCopyWith<ClassListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassListItemCopyWith<$Res> {
  factory $ClassListItemCopyWith(
          ClassListItem value, $Res Function(ClassListItem) then) =
      _$ClassListItemCopyWithImpl<$Res, ClassListItem>;
  @useResult
  $Res call(
      {@JsonKey(name: 'class_id') String classId,
      @JsonKey(name: 'class_name') String className,
      @JsonKey(name: 'attached_code') String? attachedCode,
      @JsonKey(name: 'class_type') String classType,
      @JsonKey(name: 'lecturer_name') String lecturerName,
      @JsonKey(name: 'student_count') int studentCount,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      String status});
}

/// @nodoc
class _$ClassListItemCopyWithImpl<$Res, $Val extends ClassListItem>
    implements $ClassListItemCopyWith<$Res> {
  _$ClassListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClassListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? className = null,
    Object? attachedCode = freezed,
    Object? classType = null,
    Object? lecturerName = null,
    Object? studentCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      classId: null == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String,
      className: null == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String,
      attachedCode: freezed == attachedCode
          ? _value.attachedCode
          : attachedCode // ignore: cast_nullable_to_non_nullable
              as String?,
      classType: null == classType
          ? _value.classType
          : classType // ignore: cast_nullable_to_non_nullable
              as String,
      lecturerName: null == lecturerName
          ? _value.lecturerName
          : lecturerName // ignore: cast_nullable_to_non_nullable
              as String,
      studentCount: null == studentCount
          ? _value.studentCount
          : studentCount // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ClassListItemImplCopyWith<$Res>
    implements $ClassListItemCopyWith<$Res> {
  factory _$$ClassListItemImplCopyWith(
          _$ClassListItemImpl value, $Res Function(_$ClassListItemImpl) then) =
      __$$ClassListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'class_id') String classId,
      @JsonKey(name: 'class_name') String className,
      @JsonKey(name: 'attached_code') String? attachedCode,
      @JsonKey(name: 'class_type') String classType,
      @JsonKey(name: 'lecturer_name') String lecturerName,
      @JsonKey(name: 'student_count') int studentCount,
      @JsonKey(name: 'start_date') String startDate,
      @JsonKey(name: 'end_date') String endDate,
      String status});
}

/// @nodoc
class __$$ClassListItemImplCopyWithImpl<$Res>
    extends _$ClassListItemCopyWithImpl<$Res, _$ClassListItemImpl>
    implements _$$ClassListItemImplCopyWith<$Res> {
  __$$ClassListItemImplCopyWithImpl(
      _$ClassListItemImpl _value, $Res Function(_$ClassListItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClassListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = null,
    Object? className = null,
    Object? attachedCode = freezed,
    Object? classType = null,
    Object? lecturerName = null,
    Object? studentCount = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(_$ClassListItemImpl(
      classId: null == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String,
      className: null == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String,
      attachedCode: freezed == attachedCode
          ? _value.attachedCode
          : attachedCode // ignore: cast_nullable_to_non_nullable
              as String?,
      classType: null == classType
          ? _value.classType
          : classType // ignore: cast_nullable_to_non_nullable
              as String,
      lecturerName: null == lecturerName
          ? _value.lecturerName
          : lecturerName // ignore: cast_nullable_to_non_nullable
              as String,
      studentCount: null == studentCount
          ? _value.studentCount
          : studentCount // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$ClassListItemImpl implements _ClassListItem {
  const _$ClassListItemImpl(
      {@JsonKey(name: 'class_id') required this.classId,
      @JsonKey(name: 'class_name') required this.className,
      @JsonKey(name: 'attached_code') this.attachedCode,
      @JsonKey(name: 'class_type') required this.classType,
      @JsonKey(name: 'lecturer_name') required this.lecturerName,
      @JsonKey(name: 'student_count') required this.studentCount,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      required this.status});

  factory _$ClassListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassListItemImplFromJson(json);

  @override
  @JsonKey(name: 'class_id')
  final String classId;
  @override
  @JsonKey(name: 'class_name')
  final String className;
  @override
  @JsonKey(name: 'attached_code')
  final String? attachedCode;
  @override
  @JsonKey(name: 'class_type')
  final String classType;
  @override
  @JsonKey(name: 'lecturer_name')
  final String lecturerName;
  @override
  @JsonKey(name: 'student_count')
  final int studentCount;
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
    return 'ClassListItem(classId: $classId, className: $className, attachedCode: $attachedCode, classType: $classType, lecturerName: $lecturerName, studentCount: $studentCount, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassListItemImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.attachedCode, attachedCode) ||
                other.attachedCode == attachedCode) &&
            (identical(other.classType, classType) ||
                other.classType == classType) &&
            (identical(other.lecturerName, lecturerName) ||
                other.lecturerName == lecturerName) &&
            (identical(other.studentCount, studentCount) ||
                other.studentCount == studentCount) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, classId, className, attachedCode,
      classType, lecturerName, studentCount, startDate, endDate, status);

  /// Create a copy of ClassListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassListItemImplCopyWith<_$ClassListItemImpl> get copyWith =>
      __$$ClassListItemImplCopyWithImpl<_$ClassListItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassListItemImplToJson(
      this,
    );
  }
}

abstract class _ClassListItem implements ClassListItem {
  const factory _ClassListItem(
      {@JsonKey(name: 'class_id') required final String classId,
      @JsonKey(name: 'class_name') required final String className,
      @JsonKey(name: 'attached_code') final String? attachedCode,
      @JsonKey(name: 'class_type') required final String classType,
      @JsonKey(name: 'lecturer_name') required final String lecturerName,
      @JsonKey(name: 'student_count') required final int studentCount,
      @JsonKey(name: 'start_date') required final String startDate,
      @JsonKey(name: 'end_date') required final String endDate,
      required final String status}) = _$ClassListItemImpl;

  factory _ClassListItem.fromJson(Map<String, dynamic> json) =
      _$ClassListItemImpl.fromJson;

  @override
  @JsonKey(name: 'class_id')
  String get classId;
  @override
  @JsonKey(name: 'class_name')
  String get className;
  @override
  @JsonKey(name: 'attached_code')
  String? get attachedCode;
  @override
  @JsonKey(name: 'class_type')
  String get classType;
  @override
  @JsonKey(name: 'lecturer_name')
  String get lecturerName;
  @override
  @JsonKey(name: 'student_count')
  int get studentCount;
  @override
  @JsonKey(name: 'start_date')
  String get startDate;
  @override
  @JsonKey(name: 'end_date')
  String get endDate;
  @override
  String get status;

  /// Create a copy of ClassListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassListItemImplCopyWith<_$ClassListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
