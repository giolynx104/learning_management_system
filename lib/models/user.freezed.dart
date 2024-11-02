// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  int get id => throw _privateConstructorUsedError;
  String? get ho => throw _privateConstructorUsedError;
  String? get ten => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  @JsonKey(name: 'active')
  String get active => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_list', defaultValue: [])
  List<ClassListItem> get classList => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {int id,
      String? ho,
      String? ten,
      String username,
      String token,
      @JsonKey(name: 'active') String active,
      String role,
      String? avatar,
      @JsonKey(name: 'class_list', defaultValue: [])
      List<ClassListItem> classList});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ho = freezed,
    Object? ten = freezed,
    Object? username = null,
    Object? token = null,
    Object? active = null,
    Object? role = null,
    Object? avatar = freezed,
    Object? classList = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      ho: freezed == ho
          ? _value.ho
          : ho // ignore: cast_nullable_to_non_nullable
              as String?,
      ten: freezed == ten
          ? _value.ten
          : ten // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      classList: null == classList
          ? _value.classList
          : classList // ignore: cast_nullable_to_non_nullable
              as List<ClassListItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? ho,
      String? ten,
      String username,
      String token,
      @JsonKey(name: 'active') String active,
      String role,
      String? avatar,
      @JsonKey(name: 'class_list', defaultValue: [])
      List<ClassListItem> classList});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ho = freezed,
    Object? ten = freezed,
    Object? username = null,
    Object? token = null,
    Object? active = null,
    Object? role = null,
    Object? avatar = freezed,
    Object? classList = null,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      ho: freezed == ho
          ? _value.ho
          : ho // ignore: cast_nullable_to_non_nullable
              as String?,
      ten: freezed == ten
          ? _value.ten
          : ten // ignore: cast_nullable_to_non_nullable
              as String?,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      classList: null == classList
          ? _value._classList
          : classList // ignore: cast_nullable_to_non_nullable
              as List<ClassListItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      this.ho,
      this.ten,
      required this.username,
      required this.token,
      @JsonKey(name: 'active') required this.active,
      required this.role,
      this.avatar,
      @JsonKey(name: 'class_list', defaultValue: [])
      required final List<ClassListItem> classList})
      : _classList = classList;

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final int id;
  @override
  final String? ho;
  @override
  final String? ten;
  @override
  final String username;
  @override
  final String token;
  @override
  @JsonKey(name: 'active')
  final String active;
  @override
  final String role;
  @override
  final String? avatar;
  final List<ClassListItem> _classList;
  @override
  @JsonKey(name: 'class_list', defaultValue: [])
  List<ClassListItem> get classList {
    if (_classList is EqualUnmodifiableListView) return _classList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_classList);
  }

  @override
  String toString() {
    return 'User(id: $id, ho: $ho, ten: $ten, username: $username, token: $token, active: $active, role: $role, avatar: $avatar, classList: $classList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ho, ho) || other.ho == ho) &&
            (identical(other.ten, ten) || other.ten == ten) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            const DeepCollectionEquality()
                .equals(other._classList, _classList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, ho, ten, username, token,
      active, role, avatar, const DeepCollectionEquality().hash(_classList));

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final int id,
      final String? ho,
      final String? ten,
      required final String username,
      required final String token,
      @JsonKey(name: 'active') required final String active,
      required final String role,
      final String? avatar,
      @JsonKey(name: 'class_list', defaultValue: [])
      required final List<ClassListItem> classList}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  int get id;
  @override
  String? get ho;
  @override
  String? get ten;
  @override
  String get username;
  @override
  String get token;
  @override
  @JsonKey(name: 'active')
  String get active;
  @override
  String get role;
  @override
  String? get avatar;
  @override
  @JsonKey(name: 'class_list', defaultValue: [])
  List<ClassListItem> get classList;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassListItem _$ClassListItemFromJson(Map<String, dynamic> json) {
  return _ClassListItem.fromJson(json);
}

/// @nodoc
mixin _$ClassListItem {
  @JsonKey(name: 'class_id')
  String get classId => throw _privateConstructorUsedError;
  @JsonKey(name: 'class_name')
  String get className => throw _privateConstructorUsedError;
  @JsonKey(name: 'lecturer_name')
  String get lecturerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'student_count')
  int get studentCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get endDate => throw _privateConstructorUsedError;
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
      @JsonKey(name: 'lecturer_name') String lecturerName,
      @JsonKey(name: 'student_count') int studentCount,
      @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
      DateTime startDate,
      @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
      DateTime endDate,
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
      @JsonKey(name: 'lecturer_name') String lecturerName,
      @JsonKey(name: 'student_count') int studentCount,
      @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
      DateTime startDate,
      @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
      DateTime endDate,
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
class _$ClassListItemImpl implements _ClassListItem {
  const _$ClassListItemImpl(
      {@JsonKey(name: 'class_id') required this.classId,
      @JsonKey(name: 'class_name') required this.className,
      @JsonKey(name: 'lecturer_name') required this.lecturerName,
      @JsonKey(name: 'student_count') required this.studentCount,
      @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
      required this.startDate,
      @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
      required this.endDate,
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
  @JsonKey(name: 'lecturer_name')
  final String lecturerName;
  @override
  @JsonKey(name: 'student_count')
  final int studentCount;
  @override
  @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime endDate;
  @override
  final String status;

  @override
  String toString() {
    return 'ClassListItem(classId: $classId, className: $className, lecturerName: $lecturerName, studentCount: $studentCount, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassListItemImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.className, className) ||
                other.className == className) &&
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
  int get hashCode => Object.hash(runtimeType, classId, className, lecturerName,
      studentCount, startDate, endDate, status);

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
      @JsonKey(name: 'lecturer_name') required final String lecturerName,
      @JsonKey(name: 'student_count') required final int studentCount,
      @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
      required final DateTime startDate,
      @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
      required final DateTime endDate,
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
  @JsonKey(name: 'lecturer_name')
  String get lecturerName;
  @override
  @JsonKey(name: 'student_count')
  int get studentCount;
  @override
  @JsonKey(name: 'start_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date', fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get endDate;
  @override
  String get status;

  /// Create a copy of ClassListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClassListItemImplCopyWith<_$ClassListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
