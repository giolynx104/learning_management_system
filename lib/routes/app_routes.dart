import 'package:flutter/material.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/screens/class_management.dart';
import 'package:learning_management_system/screens/create_class_screen.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String classRegistration = '/class_registration';
  static const String classManagement = '/class_management';
  static const String createClass = '/create_class';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case signin:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case classRegistration:
        return MaterialPageRoute(builder: (_) => const ClassRegistrationScreen());
      case classManagement:
        return MaterialPageRoute(builder: (_) => const ClassManagementScreen());
      case createClass:
        return MaterialPageRoute(builder: (_) => const CreateClassScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
    }
  }
}
