/// Contains common API response codes and other API-related constants
class ApiConstants {
  const ApiConstants._();

  /// Response code indicating a successful operation
  static const String successCode = '1000';

  /// Response code indicating an expired session
  static const String sessionExpiredCode = '9998';

  /// Response code indicating no data found
  static const String noDataCode = '9994';

  /// Response code indicating unauthorized role
  static const String unauthorizedRoleCode = '1009';

  /// Base endpoints
  static const String baseEndpointV4 = '/it4788';
  static const String baseEndpointV5 = '/it5023e';
  
  /// Auth endpoints (V4)
  static const String login = '$baseEndpointV4/login';
  static const String signup = '$baseEndpointV4/signup';
  static const String logout = '$baseEndpointV4/logout';
  static const String getVerifyCode = '$baseEndpointV4/get_verify_code';
  static const String checkVerifyCode = '$baseEndpointV4/check_verify_code';
  static const String getUserInfo = '$baseEndpointV4/get_user_info';
  static const String changePassword = '$baseEndpointV4/change_password';
  static const String changeInfoAfterSignup = '$baseEndpointV4/change_info_after_signup';

  /// Class endpoints (V5)
  static const String createClass = '$baseEndpointV5/create_class';
  static const String getClassList = '$baseEndpointV5/get_class_list';
  static const String registerClass = '$baseEndpointV5/register_class';
  static const String editClass = '$baseEndpointV5/edit_class';
  static const String deleteClass = '$baseEndpointV5/delete_class';
  static const String getBasicClassInfo = '$baseEndpointV5/get_basic_class_info';
  static const String getClassInfo = '$baseEndpointV5/get_class_info';

  /// Material endpoints (V5)
  static const String getMaterialList = '$baseEndpointV5/get_material_list';
  static const String uploadMaterial = '$baseEndpointV5/upload_material';
  static const String deleteMaterial = '$baseEndpointV5/delete_material';
  static const String editMaterial = '$baseEndpointV5/edit_material';

  /// Survey endpoints (V5)
  static const String getAllSurveys = '$baseEndpointV5/get_all_surveys';
  static const String createSurvey = '$baseEndpointV5/create_survey';
  static const String editSurvey = '$baseEndpointV5/edit_survey';
  static const String deleteSurvey = '$baseEndpointV5/delete_survey';
  static const String getSurveyResponse = '$baseEndpointV5/get_survey_response';
  static const String getSubmission = '$baseEndpointV5/get_submission';
  static const String submitSurvey = '$baseEndpointV5/submit_survey';

  /// Attendance endpoints (V5)
  static const String takeAttendance = '$baseEndpointV5/take_attendance';
  static const String getAttendanceList = '$baseEndpointV5/get_attendance_list';

  /// Notification endpoints (V5)
  static const String getNotifications = '$baseEndpointV5/get_notifications';
  static const String sendNotification = '$baseEndpointV5/send_notification';
  static const String getUnreadCount = '$baseEndpointV5/get_unread_notification_count';
  static const String markAsRead = '$baseEndpointV5/mark_notification_as_read';
} 