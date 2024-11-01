import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system/routes/destinations.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/screens/absence_request_screen.dart';
import 'package:learning_management_system/screens/class_management.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/create_class_screen.dart';
import 'package:learning_management_system/screens/create_survey_screen.dart';
import 'package:learning_management_system/screens/detailed_roll_call_info_screen.dart';
import 'package:learning_management_system/screens/modify_class_screen.dart';
import 'package:learning_management_system/screens/notification_screen.dart';
import 'package:learning_management_system/screens/roll_call_action_screen.dart';
import 'package:learning_management_system/screens/roll_call_management_screen.dart';
import 'package:learning_management_system/screens/student_home_screen.dart';
import 'package:learning_management_system/routes/custom_layout_scaffold.dart';
import 'package:learning_management_system/screens/submit_survey_screen.dart';
import 'package:learning_management_system/screens/survey_list_screen.dart';
import 'package:learning_management_system/screens/teacher_home_screen.dart';
import 'package:learning_management_system/screens/upload_file_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final studentRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.studentHome,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LayoutScaffold(
        navigationShell: navigationShell, destinations: studentDestinations,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.studentHome,
              builder: (context, state) => const StudentHomeScreen() , 
              routes: [
                GoRoute(
                  path: Routes.absentRequest,
                  builder: (context,state)=> const AbsenceRequestScreen(),
                  ),
                GoRoute(
                  path: Routes.surveyList,
                  builder: (context,state)=> const SurveyListScreen(),
                  routes: [
                    GoRoute(
                      path: Routes.submitSurvey,
                      builder: (context,state)=> SubmitSurveyScreen(
                        survey: state.extra as SmallSurvey , ),
                    ),  
                  ],
                  ),
                
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.notification,
              builder: (context, state) => const NotificationScreen(), 
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.classRegistration,
              builder: (context, state) => const ClassRegistrationScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
final teacherRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.teacherHome,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LayoutScaffold(
        navigationShell: navigationShell, destinations: teacherDestinations,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.teacherHome,
              builder: (context, state) => const TeacherHomeScreen() , 
              routes: [
                GoRoute(
                  path: Routes.createClass,
                  builder: (context,state)=> const CreateClassScreen()
                  ),
                 
                GoRoute(
                  path: Routes.modifyClass,
                  builder: (context,state)=> const ModifyClassScreen()
                  ),
                GoRoute(
                  path: Routes.rollCall,
                  builder: (context,state)=> const RollCallScreen()
                  ),
                GoRoute(
                  path: Routes.detailedRollCall,
                  builder: (context,state)=> const DetailedRollCallInfoScreen()
                  ),
                GoRoute(
                  path: Routes.rollCallAction,
                  builder: (context,state)=> const RollCallActionScreen()
                  ),
                GoRoute(
                  path: Routes.createSurvey,
                  builder: (context,state)=> const CreateSurveyScreen()
                  ),
                GoRoute(
                  path: Routes.uploadFile,
                  builder: (context,state)=> const UploadFileScreen()
                  ),
              ],
            ),
          ],
        ),
       
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.notification,
              builder: (context, state) => const NotificationScreen(), 
             
            ),
          ],
        ),
         StatefulShellBranch(
          routes: [
             GoRoute(
                  path: Routes.classManagement,
                  builder: (context,state)=> const ClassManagementScreen()
                  ),
          ],
        ),
      ],
    ),
  ],
);
