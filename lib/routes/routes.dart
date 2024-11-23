class Routes {
  Routes._();
  static const String home = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String notification = '/notification';
  static const String studentHome = '/student_home';
  static const String classRegistration = 'register';
  static const String absentRequest = 'absence-request/:classId';
  static const String nestedAbsentRequest = '/classes/absence-request/:classId';
  static const String surveyList = 'survey_list';
  static const String nestedSurveyList = '/student_home/survey_list';
  static const String submitSurvey = 'submit_survey';
  static const String nestedSubmitSurvey =
      '/student_home/survey_list/submit_survey';
  static const String teacherHome = '/teacher_home';
  static const String classManagement = '/class_management';
  static const String createClass = '/classes/create';
  static const String nestedCreateClass = '/teacher_home/create_class';
  static const String modifyClass = 'modify';
  static const String nestedModifyClass = '/classes/modify/:classId';
  static const String rollCall = 'roll-call/:classId';
  static const String nestedRollCall = '/classes/roll-call/:classId';
  static const String detailedRollCall = 'detailed-roll-call/:classId';
  static const String nestedDetailedRollCall =
      '/classes/detailed-roll-call/:classId';
  static const String rollCallAction = 'roll-call-action/:classId';
  static const String nestedRollCallAction =
      '/classes/roll-call-action/:classId';
  static const String createAssignment = 'create_assignment';
  static const String nestedCreateAssignment =
      '/teacher_home/create_assignment';
  static const String uploadFile = 'files/:classId';
  static const String nestedUploadFile = '/classes/files/:classId';
  static const String teacherSurveyList = 'assignments/:classId';
  static const String nestedTeacherSurveyList = '/classes/assignments/:classId';
  static const String createSurvey = 'create_survey';
  static const String nestedCreateSurvey =
      '/teacher_home/teacher_survey_list/create_survey';
  static const String editSurvey = 'edit_survey';
  static const String nestedEditSurvey =
      '/teacher_home/teacher_survey_list/edit_survey';
  static const String nestedClassRegistration = '/class_management/register';
  static const String notifications = '/notifications';
  static const String detailedAttendanceList =
      'detailed-attendance-list/:classId';
}
