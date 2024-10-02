import 'package:flutter/material.dart';
import 'package:learning_management_system/screens/create_survey_screen.dart';
import 'package:learning_management_system/screens/submit_survey_screen.dart';
import 'package:learning_management_system/screens/survey_list_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/signin_screen.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String createSurvey = '/create_survey';
  static const String submitSurvey = '/submit_survey';
  static const String surveyList = '/survey_list';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case createSurvey:
        return MaterialPageRoute(builder: (_) => const CreateSurveyScreen());
      case submitSurvey:
      // Extract the survey from the settings.arguments
        final Survey survey = settings.arguments as Survey;
        return MaterialPageRoute(
          builder: (_) => SubmitSurveyScreen(
            survey: SmallSurvey(name: survey.name,
              description: survey.description,
              file: survey.file,
              answerDescription: survey.answerDescription,
              answerFile: survey.answerFile,
              endTime: survey.endTime), // Replace with your actual Survey object
          ), // Pass the survey to the screen
        );
      case surveyList:
        return MaterialPageRoute(builder: (_) => const SurveyListScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
    }
  }
}
