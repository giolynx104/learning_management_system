import 'package:flutter/material.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/screens/class_management.dart';
import 'package:learning_management_system/screens/create_class_screen.dart';
import 'package:learning_management_system/screens/modify_class_screen.dart';
import 'package:learning_management_system/screens/roll_call_management_screen.dart';
import 'package:learning_management_system/screens/detailed_roll_call_info_screen.dart';
import 'package:learning_management_system/screens/roll_call_action_screen.dart';

class AppRoutes {
  static const String signup = '/signup';
  static const String signin = '/signin';
  static const String classRegistration = '/class_registration';
  static const String classManagement = '/class_management';
  static const String createClass = '/create_class';
  static const String modifyClass = '/modify_class';
  static const String rollCall = '/roll_call';
  static const String detailedRollCall = '/detailed_roll_call';
  static const String rollCallAction = '/roll_call_action';

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
      case modifyClass:
        return MaterialPageRoute(builder: (_) => const ModifyClassScreen());
      case rollCall:
        return MaterialPageRoute(builder: (_) => const RollCallScreen());
      case detailedRollCall:
        return MaterialPageRoute(builder: (_) => const DetailedRollCallInfoScreen());
      case rollCallAction:
        return MaterialPageRoute(builder: (_) => const RollCallActionScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
    }
  }
}
