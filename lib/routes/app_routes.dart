import 'package:flutter/material.dart';
import 'package:learning_management_system/screens/create_survey_screen.dart';
import 'package:learning_management_system/screens/submit_survey_screen.dart';
import 'package:learning_management_system/screens/survey_list_screen.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/screens/student_home_screen.dart';
import 'package:learning_management_system/screens/teacher_home_screen.dart';
import 'package:learning_management_system/screens/notification_screen.dart';
import 'package:learning_management_system/screens/class_management_screen.dart';
import 'package:learning_management_system/screens/create_class_screen.dart';
import 'package:learning_management_system/screens/modify_class_screen.dart';
import 'package:learning_management_system/screens/roll_call_management_screen.dart';
import 'package:learning_management_system/screens/detailed_roll_call_info_screen.dart';
import 'package:learning_management_system/screens/roll_call_action_screen.dart';
import 'package:learning_management_system/screens/upload_file_screen.dart';
import 'package:learning_management_system/screens/screen_chat.dart';
import 'package:learning_management_system/screens/absence_req_screen.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String createSurvey = '/create_survey';
  static const String submitSurvey = '/submit_survey';
  static const String surveyList = '/survey_list';
  static const String classRegistration = '/class_registration';
  static const String studentHome = '/student_home';
  static const String teacherHome = '/teacher_home';
  static const String notification = '/notification_screen';
  static const String classManagement = '/class_management';
  static const String createClass = '/create_class';
  static const String modifyClass = '/modify_class';
  static const String rollCall = '/roll_call';
  static const String detailedRollCall = '/detailed_roll_call';
  static const String rollCallAction = '/roll_call_action';
  static const String createAssignment = '/create_assignment';
  static const String uploadFile = '/upload_file';
  static const String screenChatStudent = '/screen_chat';
  static const String absenceRequestScreen = '/absence_request_screen';
  static const String absenceReqScreen = '/absence_req_screen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case createSurvey:
        return MaterialPageRoute(builder: (_) => const CreateSurveyScreen());
      case submitSurvey:
        final Survey survey = settings.arguments as Survey;
        return MaterialPageRoute(
          builder: (_) => SubmitSurveyScreen(
            survey: SmallSurvey(
                name: survey.name,
                description: survey.description,
                file: survey.file,
                answerDescription: survey.answerDescription,
                answerFile: survey.answerFile,
                endTime: survey.endTime),
          ),
        );
      case surveyList:
        return MaterialPageRoute(builder: (_) => const SurveyListScreen());
      case classRegistration:
        return MaterialPageRoute(
            builder: (_) => const ClassRegistrationScreen());
      case studentHome:
        return MaterialPageRoute(builder: (_) => const StudentHomeScreen());
      case teacherHome:
        return MaterialPageRoute(builder: (_) => const TeacherHomeScreen());
      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case classManagement:
        return MaterialPageRoute(builder: (_) => const ClassManagementScreen());
      case createClass:
        return MaterialPageRoute(builder: (_) => const CreateClassScreen());
      case modifyClass:
        return MaterialPageRoute(builder: (_) => const ModifyClassScreen());
      case rollCall:
        return MaterialPageRoute(builder: (_) => const RollCallScreen());
      case detailedRollCall:
        return MaterialPageRoute(
            builder: (_) => const DetailedRollCallInfoScreen());
      case rollCallAction:
        return MaterialPageRoute(builder: (_) => const RollCallActionScreen());
      // case createAssignment:
      //   return MaterialPageRoute(builder: (_) => const CreateAssignmentScreen());
      case uploadFile:
        return MaterialPageRoute(builder: (_) => const UploadFileScreen());
      case screenChatStudent:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
      case absenceRequestScreen:
        return MaterialPageRoute(
            builder: (_) => const absenceRequestScreenNew());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
