import 'package:flutter/material.dart';
import 'package:learning_management_system/screens/create_survey_screen.dart';
import 'package:learning_management_system/screens/submit_survey_screen.dart';
import 'package:learning_management_system/screens/survey_list_screen.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/screens/upload_file_screen.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String createSurvey = '/create_survey';
  static const String submitSurvey = '/submit_survey';
  static const String surveyList = '/survey_list';
  static const String classRegistration = '/class_registration';
  static const String createAssignment = '/Assignment';
  static const String uploadFile = '/uploadFile';

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
      case createAssignment:
        return MaterialPageRoute(builder: (_) => CreateSurveyScreen());
      case uploadFile:
        return MaterialPageRoute(builder: (_) => const UploadFileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
    }
  }
}
