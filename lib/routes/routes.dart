class Routes {
  Routes._();
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String notification = '/notification_screen';
  static const String studentHome = '/student_home';
  static const String classRegistration = '/class_registration';
  static const String absentRequest = 'absent_request';
  static const String nestedAbsentRequest = '/student_home/absent_request';
  static const String surveyList = 'survey_list';
  static const String nestedSurveyList = '/student_home/survey_list';
  static const String submitSurvey = 'submit_survey';
  static const String nestedSubmitSurvey = '/student_home/survey_list/submit_survey';
  static const String teacherHome = '/teacher_home';
  static const String classManagement = '/class_management';
  static const String createClass = 'create_class';
  static const String nestedCreateClass = '/teacher_home/create_class';
  static const String modifyClass = 'modify_class';
  static const String nestedModifyClass = '/teacher_home/modify_class';
  static const String rollCall = 'roll_call';
  static const String nestedRollCall = '/teacher_home/roll_call';
  static const String detailedRollCall = 'detailed_roll_call';
  static const String nestedDetailedRollCall = '/teacher_home/detailed_roll_call';
  static const String rollCallAction = 'roll_call_action';
  static const String nestedRollCallAction = '/teacher_home/roll_call_action';
  static const String createAssignment = 'create_assignment';
  static const String nestedCreateAssignment = '/teacher_home/create_assignment';
  static const String uploadFile = 'upload_file';
  static const String nestedUploadFile = '/teacher_home/upload_file';
  static const String createSurvey = 'create_survey';
  static const String nestedCreateSurvey = '/teacher_home/create_survey';
 
}