import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/custom_layout_scaffold.dart';
import 'package:learning_management_system/routes/destinations.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/screens/absence_request_list_screen.dart';
import 'package:learning_management_system/screens/absence_request_screen.dart';
import 'package:learning_management_system/screens/screen_chat.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/class_management_screen.dart';
import 'package:learning_management_system/screens/create_class_screen.dart';
import 'package:learning_management_system/screens/detailed_roll_call_info_screen.dart';
import 'package:learning_management_system/screens/modify_class_screen.dart';
import 'package:learning_management_system/screens/notification_screen.dart';
import 'package:learning_management_system/screens/roll_call_action_screen.dart';
import 'package:learning_management_system/screens/roll_call_management_screen.dart';
import 'package:learning_management_system/screens/student_home_screen.dart';
import 'package:learning_management_system/screens/student_survey_list_screen.dart';
import 'package:learning_management_system/screens/teacher_home_screen.dart';
import 'package:learning_management_system/screens/teacher_survey_list_screen.dart';
import 'package:learning_management_system/screens/upload_file_screen.dart';
import 'package:learning_management_system/widgets/scaffold_with_navigation.dart';
import 'package:learning_management_system/screens/profile_screen.dart';
import 'package:learning_management_system/screens/detailed_attendance_list_screen.dart';
import 'package:learning_management_system/screens/student_attendance_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.signin,
    refreshListenable: router,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      debugPrint('🚦 Router redirect - Current path: ${state.uri.path}');

      return authState.when(
        data: (user) {
          debugPrint('👤 User in redirect: ${user?.toJson()}');

          if (user == null) {
            if (state.uri.path == Routes.signin ||
                state.uri.path == Routes.signup) {
              return null;
            }
            return Routes.signin;
          }

          if (state.uri.path == Routes.signin ||
              state.uri.path == Routes.signup) {
            return Routes.home;
          }

          return null;
        },
        loading: () => null,
        error: (_, __) => Routes.signin,
      );
    },
    routes: [
      // Auth routes
      GoRoute(
        path: Routes.signin,
        name: 'signin',
        builder: (context, state) => const CustomLayoutScaffold(
          hideAppBar: true,
          child: SignInScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signup,
        name: 'signup',
        builder: (context, state) => const CustomLayoutScaffold(
          hideAppBar: true,
          child: SignUpScreen(),
        ),
      ),

      // Main app shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final container = ProviderScope.containerOf(context);
          final isStudent =
              container.read(authProvider).value?.role.toLowerCase() ==
                  'student';

          return CustomLayoutScaffold(
            child: ScaffoldWithNavigation(
              navigationShell: navigationShell,
              destinations:
                  isStudent ? studentDestinations : teacherDestinations,
            ),
          );
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                name: 'home',
                builder: (context, state) {
                  final container = ProviderScope.containerOf(context);
                  final isStudent =
                      container.read(authProvider).value?.role.toLowerCase() ==
                          'student';
                  return isStudent
                      ? const StudentHomeScreen()
                      : const TeacherHomeScreen();
                },
              ),
            ],
          ),
          // Classes Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.classManagement,
                name: 'classes',
                builder: (context, state) => const ClassManagementScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    name: 'createClass',
                    builder: (context, state) => const CreateClassScreen(),
                  ),
                  GoRoute(
                    path: Routes.modifyClass,
                    name: 'modifyClass',
                    builder: (context, state) => ModifyClassScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.rollCall,
                    name: 'roll-call',
                    builder: (context, state) => RollCallScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.detailedRollCall,
                    name: 'detailedRollCall',
                    builder: (context, state) => DetailedRollCallInfoScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    name: Routes.rollCallAction,
                    path: 'roll-call-action/:classId',
                    builder: (context, state) => RollCallActionScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    name: Routes.detailedAttendanceList,
                    path: 'detailed-attendance-list/:classId',
                    builder: (context, state) => DetailedAttendanceListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.studentSurveyList,
                    builder: (context, state) => StudentSurveyListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.teacherSurveyList,
                    builder: (context, state) => TeacherSurveyListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.uploadFile,
                    builder: (context, state) => UploadFileScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    name: Routes.absenceRequestList,
                    path: 'absence-requests/:classId',
                    builder: (context, state) => AbsenceRequestListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    name: Routes.studentAttendance,
                    path: 'student-attendance/:classId',
                    builder: (context, state) => StudentAttendanceScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    name: Routes.absenceRequest,
                    path: 'absence-request/:classId',
                    builder: (context, state) => AbsenceRequestScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Chat Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                name: 'chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Notification route
      GoRoute(
        path: Routes.notification,
        name: 'notification',
        builder: (context, state) => const CustomLayoutScaffold(
          child: NotificationScreen(),
        ),
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      debugPrint('🔄 Auth state changed: $next');
      notifyListeners();
    });
  }
}

final appRouter = routerProvider;
