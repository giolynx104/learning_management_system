class Routes {
  Routes._();

  // Auth routes
  static const String signin = '/signin';
  static const String signup = '/signup';

  // Main navigation routes
  static const String home = '/';
  static const String notification = '/notification';

  // Class management routes
  static const String classManagement = '/classes';
  static const String classRegistration = 'register';
  static const String createClass = 'create';
  static const String modifyClass = 'modify/:classId';
  static const String rollCall = 'roll-call/:classId';
  static const String detailedRollCall = 'detailed-roll-call/:classId';
  static const String rollCallAction = 'roll-call-action/:classId';

  // Survey/Assignment routes
  static const String studentSurveyList = 'student-assignments/:classId';
  static const String teacherSurveyList = 'teacher-assignments/:classId';
  static const String submitSurvey = 'submit-survey';
  static const String createSurvey = 'create-survey';
  static const String editSurvey = 'edit-survey/:surveyId';

  // Attendance routes
  static const String detailedAttendanceList = 'detailed-attendance-list/:classId';
  static const String absenceRequestList = 'absence-requests/:classId';
  static const String studentAttendance = 'student-attendance/:classId';
  static const String absenceRequest = 'absence-request/:classId';

  // Material routes
  static const String materialList = 'materials/:classId';
  static const String uploadMaterial = 'materials/:classId/upload';

  // Helper methods for generating full paths
  static String getRollCallPath(String classId) => '/classes/roll-call/$classId';
  static String getModifyClassPath(String classId) => '/classes/modify/$classId';
  static String getCreateClassPath() => '/classes/create';
  static String getSubmitSurveyPath() => '/classes/submit-survey';
  static String getCreateSurveyPath() => '/classes/create-survey';
  static String getEditSurveyPath(String surveyId) => '/classes/edit-survey/$surveyId';

  // Add helper methods for material routes
  static String getMaterialListPath(String classId) => '/classes/materials/$classId';
  static String getUploadMaterialPath(String classId) => '/classes/materials/$classId/upload';
}
