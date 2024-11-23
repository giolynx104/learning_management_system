class Routes {
  Routes._();
  static const String home = '/';
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String notification = '/notification';
  static const String studentHome = '/student_home';
  static const String classRegistration = 'register';
  static const String absentRequest = 'absent_request';
  static const String nestedAbsentRequest = '/student_home/absent_request';
  static const String surveyList = 'survey_list';
  static const String nestedSurveyList = '/student_home/survey_list';
  static const String submitSurvey = 'submit_survey';
  static const String nestedSubmitSurvey =
      '/student_home/survey_list/submit_survey';
  static const String teacherHome = '/teacher_home';
  static const String classManagement = '/class_management';
  static const String createClass = '/classes/create';
  static const String nestedCreateClass = '/teacher_home/create_class';
  static const String modifyClass = 'modify/:classId';
  static const String nestedModifyClass = '/teacher_home/modify_class';
  static const String rollCall = 'roll-call/:classId';
  static const String nestedRollCall = '/class_management/roll-call/:classId';
  static const String detailedRollCall = 'detailed-roll-call/:classId';
  static const String nestedDetailedRollCall =
      '/class_management/detailed-roll-call/:classId';
  static const String rollCallAction = 'roll-call-action/:classId';
  static const String nestedRollCallAction =
      '/class_management/roll-call-action/:classId';
  static const String createAssignment = 'create_assignment';
  static const String nestedCreateAssignment =
      '/teacher_home/create_assignment';
  static const String uploadFile = 'upload_file';
  static const String nestedUploadFile = '/teacher_home/upload_file';
  static const String teacherSurveyList = '/teacher_survey_list';
  static const String nestedTeacherSurveyList =
      '/teacher_home/teacher_survey_list';
  static const String createSurvey = 'create_survey';
  static const String nestedCreateSurvey =
      '/teacher_home/teacher_survey_list/create_survey';
  static const String editSurvey = 'edit_survey';
  static const String nestedEditSurvey =
      '/teacher_home/teacher_survey_list/edit_survey';
  static const String nestedClassRegistration = '/class_management/register';
  static const String notifications = '/notifications';
}
