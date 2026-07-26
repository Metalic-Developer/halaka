import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../core/router.dart';
import '../services/quran_database_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await QuranDatabaseService().database;
    } catch (e) {
      // ✅ إذا فشل التحميل، نتوجه لتسجيل الدخول مع إظهار خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل بيانات القرآن: $e')),
        );
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
      return;
    }
    // الباقي يتم عبر ref.listen في build
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
      next.whenData((user) {
        if (!mounted) return;
        if (user == null) {
          Navigator.pushReplacementNamed(context, AppRouter.login);
        } else {
          switch (user.role) {
            case 'teacher':
              Navigator.pushReplacementNamed(context, AppRouter.teacherDashboard);
              break;
            case 'student':
              Navigator.pushReplacementNamed(context, AppRouter.studentDashboard);
              break;
            case 'guardian':
              Navigator.pushReplacementNamed(context, AppRouter.guardianDashboard);
              break;
            case 'manager':
              Navigator.pushReplacementNamed(context, AppRouter.managerDashboard);
              break;
            default:
              Navigator.pushReplacementNamed(context, AppRouter.teacherDashboard);
          }
        }
      });
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}