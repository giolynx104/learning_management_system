import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/models/assignment.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/custom_layout_scaffold.dart';
import 'package:learning_management_system/routes/destinations.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/screens/absence_request_list_screen.dart';
import 'package:learning_management_system/screens/absence_request_screen.dart';
import 'package:learning_management_system/screens/attendance_management_screen.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/screen_chat.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/class_management_screen.dart';
import 'package:learning_management_system/screens/create_class_screen.dart';
import 'package:learning_management_system/screens/modify_class_screen.dart';
import 'package:learning_management_system/screens/notification_screen.dart';
import 'package:learning_management_system/screens/student_home_screen.dart';
import 'package:learning_management_system/screens/teacher_home_screen.dart';
import 'package:learning_management_system/screens/upload_material_screen.dart';
import 'package:learning_management_system/widgets/scaffold_with_navigation.dart';
import 'package:learning_management_system/screens/profile_screen.dart';
import 'package:learning_management_system/screens/detailed_attendance_list_screen.dart';
import 'package:learning_management_system/screens/student_attendance_screen.dart';
import 'package:learning_management_system/screens/material_list_screen.dart';
import 'package:learning_management_system/screens/edit_assignment_screen.dart';
import 'package:learning_management_system/screens/create_assignment_screen.dart';
import 'package:learning_management_system/screens/response_assignment_screen.dart';
import 'package:learning_management_system/screens/submit_assignment_screen.dart';
import 'package:learning_management_system/routes/router_notifier.dart';
import 'package:learning_management_system/screens/assignment_list_screen.dart';
import 'package:learning_management_system/screens/take_attendance_screen.dart';
import 'package:learning_management_system/screens/change_password_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.signin,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // Handle loading state
      if (authState is AsyncLoading) {
        return null;
      }

      final isAuth = authState.value != null;
      final isSignInPage = state.matchedLocation == '/signin';
      final isSignUpPage = state.matchedLocation == '/signup';

      // Allow access to both signin and signup pages when not authenticated
      if (!isAuth && !isSignInPage && !isSignUpPage) {
        return '/signin';
      }

      // Redirect to home if authenticated and trying to access auth pages
      if (isAuth && (isSignInPage || isSignUpPage)) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes (outside shell)
      GoRoute(
        path: Routes.signin,
        name: Routes.signinName,
        builder: (context, state) => const CustomLayoutScaffold(
          hideAppBar: true,
          child: SignInScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signup,
        name: Routes.signupName,
        builder: (context, state) => const CustomLayoutScaffold(
          hideAppBar: true,
          child: SignUpScreen(),
        ),
      ),

      // Add the change password route here, outside the shell
      GoRoute(
        path: Routes.changePassword,
        name: Routes.changePasswordName,
        builder: (context, state) => const CustomLayoutScaffold(
          child: ChangePasswordScreen(),
        ),
      ),

      // Notification route (outside shell)
      GoRoute(
        path: Routes.notification,
        name: Routes.notificationName,
        builder: (context, state) => const CustomLayoutScaffold(
          child: NotificationScreen(),
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
                name: Routes.homeName,
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

          // Classes Branch with nested routes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.classManagement,
                name: Routes.classesName,
                builder: (context, state) => const ClassManagementScreen(),
                routes: [
                  GoRoute(
                    path: Routes.classRegistration,
                    name: Routes.classRegistrationName,
                    builder: (context, state) =>
                        const ClassRegistrationScreen(),
                  ),
                  GoRoute(
                    path: Routes.createClass,
                    name: Routes.createClassName,
                    builder: (context, state) => const CreateClassScreen(),
                  ),
                  GoRoute(
                    path: Routes.modifyClass,
                    name: Routes.modifyClassName,
                    builder: (context, state) => ModifyClassScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.attendanceManagement,
                    name: Routes.attendanceManagementName,
                    builder: (context, state) => AttendanceManagementScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.takeAttendance,
                    name: Routes.takeAttendanceName,
                    builder: (context, state) => TakeAttendanceScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.detailedAttendanceList,
                    name: Routes.detailedAttendanceListName,
                    builder: (context, state) => DetailedAttendanceListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.absenceRequestList,
                    name: Routes.absenceRequestListName,
                    builder: (context, state) => AbsenceRequestListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.studentAttendance,
                    name: Routes.studentAttendanceName,
                    builder: (context, state) => StudentAttendanceScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.absenceRequest,
                    name: Routes.absenceRequestName,
                    builder: (context, state) => AbsenceRequestScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.materialList,
                    name: Routes.materialListName,
                    builder: (context, state) => MaterialListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.uploadMaterial,
                    name: Routes.uploadMaterialName,
                    builder: (context, state) => UploadMaterialScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.editAssignment,
                    name: Routes.editAssignmentName,
                    builder: (context, state) => EditAssignmentScreen(
                      assignmentId: state.pathParameters['assignmentId'] ?? '',
                      assignment: state.extra as Assignment,
                    ),
                  ),
                  GoRoute(
                    path: Routes.responseAssignment,
                    name: Routes.responseAssignmentName,
                    builder: (context, state) => ResponseAssignmentScreen(
                      assignmentId: state.pathParameters['assignmentId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.assignments,
                    name: Routes.assignmentsName,
                    builder: (context, state) => AssignmentListScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.createAssignment,
                    name: Routes.createAssignmentName,
                    builder: (context, state) => CreateAssignmentScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  GoRoute(
                    path: Routes.submitAssignment,
                    name: Routes.submitAssignmentName,
                    builder: (context, state) => SubmitAssignmentScreen(
                      assignment: state.extra as Assignment,
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
                name: Routes.chatName,
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),

          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: Routes.profileName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return router;
});

final appRouter = routerProvider;
