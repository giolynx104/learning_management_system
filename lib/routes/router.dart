import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/auth_provider.dart';
import 'package:learning_management_system/routes/custom_layout_scaffold.dart';
import 'package:learning_management_system/routes/destinations.dart';
import 'package:learning_management_system/routes/routes.dart';
import 'package:learning_management_system/screens/screen_chat.dart';
import 'package:learning_management_system/screens/signin_screen.dart';
import 'package:learning_management_system/screens/signup_screen.dart';
import 'package:learning_management_system/screens/class_management_screen.dart';
import 'package:learning_management_system/screens/class_registration_screen.dart';
import 'package:learning_management_system/screens/create_class_screen.dart';
import 'package:learning_management_system/screens/create_survey_screen.dart';
import 'package:learning_management_system/screens/detailed_roll_call_info_screen.dart';
import 'package:learning_management_system/screens/edit_survey_screen.dart';
import 'package:learning_management_system/screens/modify_class_screen.dart';
import 'package:learning_management_system/screens/notification_screen.dart';
import 'package:learning_management_system/screens/roll_call_action_screen.dart';
import 'package:learning_management_system/screens/roll_call_management_screen.dart';
import 'package:learning_management_system/screens/student_home_screen.dart';
import 'package:learning_management_system/screens/submit_survey_screen.dart';
import 'package:learning_management_system/screens/survey_list_screen.dart';
import 'package:learning_management_system/screens/teacher_home_screen.dart';
import 'package:learning_management_system/screens/teacher_survey_list_screen.dart';
import 'package:learning_management_system/screens/upload_file_screen.dart';
import 'package:learning_management_system/screens/absence_request_screen.dart';
import 'package:learning_management_system/models/survey.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final router = RouterNotifier(ref);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.signin,
    refreshListenable: router,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      debugPrint('🚦 Router redirect - Current path: ${state.uri.path}');
      debugPrint('🔑 Auth state: $authState');

      return authState.when(
        data: (user) {
          debugPrint('👤 User in redirect: ${user?.toJson()}');
          if (user == null) {
            debugPrint('❌ No user found, redirecting to signin');
            return Routes.signin;
          }

          if (state.uri.path == Routes.signin ||
              state.uri.path == Routes.signup) {
            final route = user.role.toUpperCase() == 'STUDENT'
                ? Routes.studentHome
                : Routes.teacherHome;
            debugPrint('✅ User authenticated, redirecting to $route');
            return route;
          }

          debugPrint('🟢 No redirect needed');
          return null;
        },
        loading: () {
          debugPrint('⌛ Loading state in redirect');
          return null;
        },
        error: (error, __) {
          debugPrint('❌ Error in redirect: $error');
          return Routes.signin;
        },
      );
    },
    routes: [
      // Auth routes
      GoRoute(
        path: Routes.signin,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main app shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final container = ProviderScope.containerOf(context);
          final isStudent =
              container.read(authProvider).value?.role.toUpperCase() == 'STUDENT';

          return LayoutScaffold(
            navigationShell: navigationShell,
            destinations: isStudent ? studentDestinations : teacherDestinations,
          );
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              // Student Home
              GoRoute(
                path: Routes.studentHome,
                builder: (context, state) => const StudentHomeScreen(),
                routes: [
                  GoRoute(
                    path: Routes.absentRequest,
                    builder: (context, state) => const AbsenceRequestScreen(),
                  ),
                  GoRoute(
                    path: Routes.surveyList,
                    builder: (context, state) => const SurveyListScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.submitSurvey,
                        builder: (context, state) => SubmitSurveyScreen(
                          survey: state.extra as SmallSurvey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Teacher Home
              GoRoute(
                path: Routes.teacherHome,
                builder: (context, state) => const TeacherHomeScreen(),
                routes: [
                  GoRoute(
                    path: Routes.createClass,
                    builder: (context, state) => const CreateClassScreen(),
                  ),
                  GoRoute(
                    path: Routes.modifyClass,
                    builder: (context, state) {
                      final classId = state.extra as String?;
                      if (classId == null) {
                        // Handle the error case by showing an error screen or redirecting
                        return Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Error: No class ID provided'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('Go Back'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ModifyClassScreen(classId: classId);
                    },
                  ),
                  GoRoute(
                    path: Routes.rollCall,
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'] ?? '';
                      return RollCallScreen(classId: classId);
                    },
                  ),
                  GoRoute(
                    path: Routes.detailedRollCall,
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'];
                      if (classId == null) {
                        return const ErrorScreen(message: 'No class ID provided');
                      }
                      return DetailedRollCallInfoScreen(classId: classId);
                    },
                  ),
                  GoRoute(
                    path: Routes.rollCallAction,
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'];
                      if (classId == null) {
                        return const ErrorScreen(message: 'No class ID provided');
                      }
                      return RollCallActionScreen(classId: classId);
                    },
                  ),
                  GoRoute(
                    path: Routes.teacherSurveyList,
                    builder: (context, state) => const TeacherSurveyListScreen(),
                    routes: [
                      GoRoute(
                          path: Routes.createSurvey,
                          builder: (context, state) =>
                              const CreateSurveyScreen()),
                      GoRoute(
                        path: Routes.editSurvey,
                        builder: (context, state) => EditSurveyScreen(
                          survey: state.extra as TeacherSmallSurvey,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: Routes.uploadFile,
                    builder: (context, state) => const UploadFileScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Notifications Branch (shared)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.notification,
                builder: (context, state) => const NotificationScreen(),
              ),
            ],
          ),
          // Classes Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.classManagement,
                builder: (context, state) => const ClassManagementScreen(),
                routes: [
                  GoRoute(
                    path: 'register',
                    builder: (context, state) => const ClassRegistrationScreen(),
                  ),
                  GoRoute(
                    path: 'modify/:classId',
                    name: Routes.modifyClass,
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'];
                      if (classId == null) {
                        return Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Error: No class ID provided'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.pop(),
                                  child: const Text('Go Back'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ModifyClassScreen(classId: classId);
                    },
                  ),
                  GoRoute(
                    path: 'roll-call/:classId',
                    name: Routes.rollCall,
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'];
                      if (classId == null) {
                        return const ErrorScreen(message: 'No class ID provided');
                      }
                      return RollCallScreen(classId: classId);
                    },
                  ),
                  GoRoute(
                    path: 'detailed-roll-call/:classId',
                    name: Routes.detailedRollCall,
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'];
                      if (classId == null) {
                        return const ErrorScreen(message: 'No class ID provided');
                      }
                      return DetailedRollCallInfoScreen(classId: classId);
                    },
                  ),
                  GoRoute(
                    path: 'roll-call-action/:classId',
                    name: Routes.rollCallAction,
                    builder: (context, state) {
                      final classId = state.pathParameters['classId'];
                      if (classId == null) {
                        return const ErrorScreen(message: 'No class ID provided');
                      }
                      return RollCallActionScreen(classId: classId);
                    },
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
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
        ],
      ),
      // Add this route configuration
      GoRoute(
        path: Routes.nestedClassRegistration,
        name: Routes.classRegistration, // if you're using named routes
        builder: (context, state) => const ClassRegistrationScreen(),
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

// Replace the direct GoRouter instance with the provider
final appRouter = routerProvider;

// Add this error screen widget
class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $message'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
