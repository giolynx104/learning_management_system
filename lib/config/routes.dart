import 'package:go_router/go_router.dart';
import 'package:learning_management_system/screens/take_attendance_screen.dart';
// ... other imports ...

// Inside your router configuration
GoRoute(
  path: 'take-attendance/:classId',
  name: Routes.takeAttendanceName, // Add this constant to your Routes class
  builder: (context, state) => TakeAttendanceScreen(
    classId: state.pathParameters['classId']!,
  ),
),

// Add this to your Routes class
class Routes {
  // ... other route names ...
  static const String takeAttendanceName = 'take-attendance';
} 