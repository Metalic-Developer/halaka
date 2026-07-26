import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/teacher/teacher_dashboard.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/guardian/guardian_dashboard.dart';
import '../screens/manager/manager_dashboard.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String teacherDashboard = '/teacher-dashboard';
  static const String studentDashboard = '/student-dashboard';
  static const String guardianDashboard = '/guardian-dashboard';
  static const String managerDashboard = '/manager-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // نستخدم context لاستخراج ref لاحقاً، لكن هنا لا نملك ref مباشراً.
    // سنترك الحراسة الفعلية في Splash ونكتفي بتوليد المسارات.
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case teacherDashboard:
        return _guardedRoute(const TeacherDashboard(), 'teacher');
      case studentDashboard:
        return _guardedRoute(const StudentDashboard(), 'student');
      case guardianDashboard:
        return _guardedRoute(const GuardianDashboard(), 'guardian');
      case managerDashboard:
        return _guardedRoute(const ManagerDashboard(), 'manager');
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }

  static MaterialPageRoute _guardedRoute(Widget page, String requiredRole) {
    return MaterialPageRoute(
      builder: (context) {
        // الحصول على ref من ProviderScope
        final container = ProviderScope.containerOf(context);
        final authState = container.read(authStateProvider).valueOrNull;
        if (authState == null || authState.role != requiredRole) {
          // توجيه إلى Splash ليعيد التوجيه الصحيح
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, splash);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return page;
      },
    );
  }
}