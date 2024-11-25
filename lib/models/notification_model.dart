import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'from_user') required int fromUser,
    @JsonKey(name: 'to_user') required int toUser,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'image_url') String? imageUrl ,
    @JsonKey(name: 'sent_time') required String sentTime,
    @JsonKey(name: 'data') required NotificationData data,
    @JsonKey(name: 'title_push_notification') required String titlePushNotification,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

@freezed
class NotificationData with _$NotificationData {
  const factory NotificationData({
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'id') required String id,
  }) = _NotificationData;

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);
}
