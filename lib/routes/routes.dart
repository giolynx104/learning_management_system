class Routes {
  Routes._();

  // Route paths
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/';
  static const String notification = '/notification';
  static const String classManagement = '/classes';
  static const String classRegistration = 'register';
  static const String createClass = 'create';
  static const String modifyClass = 'modify/:classId';
  static const String rollCall = 'roll-call/:classId';
  static const String detailedRollCall = 'detailed-roll-call/:classId';
  static const String rollCallAction = 'roll-call-action/:classId';
  static const String studentSurveyList = 'student-assignments/:classId';
  static const String teacherSurveyList = 'teacher-assignments/:classId';
  static const String submitSurvey = 'submit-survey';
  static const String createSurvey = 'create-survey/:classId';
  static const String editSurvey = 'edit-survey/:surveyId';
  static const String responseSurvey = 'response-survey/:surveyId';
  static const String detailedAttendanceList = 'detailed-attendance-list/:classId';
  static const String absenceRequestList = 'absence-requests/:classId';
  static const String studentAttendance = 'student-attendance/:classId';
  static const String absenceRequest = 'absence-request/:classId';
  static const String materialList = 'materials/:classId';
  static const String uploadMaterial = 'materials/:classId/upload';
  static const String assignments = 'assignments';
  static const String takeAttendance = 'take-attendance/:classId';
  static const String changePassword = '/change-password';

  // Route names
  static const String signinName = 'signin';
  static const String signupName = 'signup';
  static const String homeName = 'home';
  static const String notificationName = 'notification';
  static const String classesName = 'classes';
  static const String classRegistrationName = 'classRegistration';
  static const String createClassName = 'createClass';
  static const String modifyClassName = 'modifyClass';
  static const String rollCallName = 'rollCall';
  static const String detailedRollCallName = 'detailedRollCall';
  static const String rollCallActionName = 'rollCallAction';
  static const String studentSurveyListName = 'studentSurveyList';
  static const String teacherSurveyListName = 'teacherSurveyList';
  static const String detailedAttendanceListName = 'detailedAttendanceList';
  static const String absenceRequestListName = 'absenceRequestList';
  static const String studentAttendanceName = 'studentAttendance';
  static const String absenceRequestName = 'absenceRequest';
  static const String materialListName = 'materialList';
  static const String uploadMaterialName = 'uploadMaterial';
  static const String chatName = 'chat';
  static const String profileName = 'profile';
  static const String editSurveyName = 'editSurvey';
  static const String createSurveyName = 'createSurvey';
  static const String submitSurveyName = 'submitSurvey';
  static const String responseSurveyName = 'responseSurvey';
  static const String assignmentsName = 'assignments';
  static const String takeAttendanceName = 'takeAttendance';
  static const String changePasswordName = 'change-password';

  // Helper methods for generating full paths
  static String getRollCallPath(String classId) => '/classes/roll-call/$classId';
  static String getModifyClassPath(String classId) => '/classes/modify/$classId';
  static String getCreateClassPath() => '/classes/create';
  static String getSubmitSurveyPath() => '/classes/submit-survey';
  static String getCreateSurveyPath(String classId) => '/classes/create-survey/$classId';
  static String getEditSurveyPath(String surveyId) => '/classes/edit-survey/$surveyId';
  static String getResponseSurveyPath(String surveyId) => '/classes/response-survey/$surveyId';
  static String getMaterialListPath(String classId) => '/classes/materials/$classId';
  static String getUploadMaterialPath(String classId) => '/classes/materials/$classId/upload';
  static String getStudentSurveyListPath(String classId) => '/classes/student-assignments/$classId';
  static String getTeacherSurveyListPath(String classId) => '/classes/teacher-assignments/$classId';
  static String getDetailedRollCallPath(String classId) => '/classes/detailed-roll-call/$classId';
  static String getRollCallActionPath(String classId) => '/classes/roll-call-action/$classId';
  static String getDetailedAttendanceListPath(String classId) => '/classes/detailed-attendance-list/$classId';
  static String getAbsenceRequestListPath(String classId) => '/classes/absence-requests/$classId';
  static String getStudentAttendancePath(String classId) => '/classes/student-attendance/$classId';
  static String getAbsenceRequestPath(String classId) => '/classes/absence-request/$classId';
  static String getClassRegistrationPath() => '/classes/register';
  static String getSignInPath() => signin;
  static String getSignUpPath() => signup;
  static String getHomePath() => home;
  static String getNotificationPath() => notification;
  static String getTakeAttendancePath(String classId) => '/classes/take-attendance/$classId';
}
