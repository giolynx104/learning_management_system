import 'package:flutter/material.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/UI/createAssigment.dart';
import 'package:learning_management_system/UI/upload_file_screen.dart';
class AppRoutes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String createAssignment ='/Assignment';
  static const String uploadFile ='uploadFile';
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case signup:
      //   return MaterialPageRoute(builder: (_) => const SignUpScreen());
      // case signin:
      //   return MaterialPageRoute(builder: (_) => const SignInScreen());
      case createAssignment:
        return MaterialPageRoute(builder: (_) =>  CreateSurveyScreen());
      case uploadFile:
        return MaterialPageRoute(builder: (_) =>  UploadFileScreen());
      default:
        return MaterialPageRoute(builder: (_) =>   CreateSurveyScreen());

        // return MaterialPageRoute(builder: (_) => const SignUpScreen());
    }
  }
}
