import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../core/router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    authState.whenData((user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      } else {
        // تحديد الدور وفتح الشاشة المناسبة
        // يمكن الحصول على الدور من بيانات المستخدم في Isar (سيتم تحميلها بعد تسجيل الدخول)
        // هنا سنؤجل إلى أن نضيف منطق جلب بيانات المستخدم بعد تسجيل الدخول.
        Navigator.pushReplacementNamed(context, AppRouter.teacherDashboard); // مؤقتاً
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}