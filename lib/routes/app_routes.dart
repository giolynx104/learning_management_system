import 'package:flutter/material.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/signin_screen.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String classRegistration = '/class_registration';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case classRegistration:
        return MaterialPageRoute(builder: (_) => const ClassRegistrationScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
    }
  }
}

