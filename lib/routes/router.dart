import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learning_management_system/providers/app_bar_provider.dart';
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
import 'package:learning_management_system/widgets/scaffold_with_navigation.dart';
import 'package:learning_management_system/screens/profile_screen.dart';

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
            return user.role.toLowerCase() == 'student' 
                ? Routes.studentHome 
                : Routes.teacherHome;
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
        builder: (context, state) => const CustomLayoutScaffold(
          hideAppBar: true,
          child: SignInScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const CustomLayoutScaffold(
          hideAppBar: true,
          child: SignUpScreen(),
        ),
      ),
      
      // Main app shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final container = ProviderScope.containerOf(context);
          final isStudent = container.read(authProvider).value?.role.toLowerCase() == 'student';

          return CustomLayoutScaffold(
            child: ScaffoldWithNavigation(
              navigationShell: navigationShell,
              destinations: isStudent ? studentDestinations : teacherDestinations,
            ),
          );
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.studentHome,
                builder: (context, state) => const StudentHomeScreen(),
              ),
              GoRoute(
                path: Routes.teacherHome,
                builder: (context, state) => const TeacherHomeScreen(),
              ),
            ],
          ),
          // Classes Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/classes',
                builder: (context, state) => const ClassManagementScreen(),
                routes: [
                  // Nested class routes
                  GoRoute(
                    path: 'modify/:classId',
                    builder: (context, state) => ModifyClassScreen(
                      classId: state.pathParameters['classId'] ?? '',
                    ),
                  ),
                  // ... (keep other class-related routes)
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
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
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
