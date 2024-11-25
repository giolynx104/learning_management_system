import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_model.freezed.dart';
part 'material_model.g.dart';

@freezed
class MaterialModel with _$MaterialModel {
  const factory MaterialModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'class_id') required String classId,
    @JsonKey(name: 'material_name') required String materialName,
    String? description,
    @JsonKey(name: 'material_type') required String materialType,
    @JsonKey(name: 'material_link') String? materialLink,

    // @JsonKey(ignore: true) String? materialLink,
  }) = _MaterialModel;
  factory MaterialModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialModelFromJson(json);
}

@freezed
class MaterialListResponse with _$MaterialListResponse {
  const factory MaterialListResponse({
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'data') required List<MaterialModel> data,
  }) = _MaterialListResponse;
  factory MaterialListResponse.fromJson(Map<String, dynamic> json) =>
      _$MaterialListResponseFromJson(json);
}

@freezed
class MaterialResponse with _$MaterialResponse {
  const factory MaterialResponse({
    @JsonKey(name: 'code') required String code,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'data') required MaterialModel data,
  }) = _MaterialResponse;

  factory MaterialResponse.fromJson(Map<String, dynamic> json) =>
      _$MaterialResponseFromJson(json);
}
