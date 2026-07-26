import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../models/session.dart';

final studentSessionsProvider = FutureProvider.family<List<Session>, ({String studentId, DateTime weekStart})>(
  (ref, params) {
    return ref.read(teacherProvider).getStudentWeeklySessions(params.studentId, params.weekStart);
  },
);

class GuardianDashboard extends ConsumerWidget {
  const GuardianDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator());

    // ✅ جلب الابن المرتبط (يمكن حفظه في User أو جدول منفصل)
    // هنا سنستخدم حقل إضاضي، في التطبيق الحقيقي يجب تخزين ابن الولي.
    // سنقوم بجلب أول طالب مرتبط بهذا الولي من Isar (بافتراض وجود علاقة)
    // للتبسيط نستخدم قيمة ديناميكية مستقاة من قاعدة البيانات
    // (يمكنك تعديلها لاحقاً حسب هيكلية بياناتك)
    // سنقوم بإنشاء Provider لجلب studentId من الـ guardian
    final studentIdAsync = ref.watch(guardianStudentIdProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('متابعة الطالب')),
      body: studentIdAsync.when(
        data: (studentId) {
          if (studentId == null) return const Center(child: Text('لا يوجد طالب مرتبط'));
          final sessionsAsync = ref.watch(studentSessionsProvider((studentId: studentId, weekStart: DateTime.now())));
          return sessionsAsync.when(
            data: (sessions) => ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text('جلسة ${session.sessionDate}'),
                  subtitle: Text('النقاط: ${session.totalPoints}'),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('خطأ: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}

// ✅ Provider مساعد لجلب studentId من الـ guardian
final guardianStudentIdProvider = FutureProvider.family<String?, String>((ref, guardianUserId) async {
  final isar = await IsarService.isar;
  // افترض وجود جدول guardians أو حقل student_id في user
  // سنبحث عن طالب مرتبط (للتبسيط نجلب أول طالب بنفس group)
  final guardian = await isar.users.getById(guardianUserId);
  if (guardian == null) return null;
  final students = await isar.users.filter()
      .roleEqualTo('student')
      .and()
      .groupSupabaseIdEqualTo(guardian.groupSupabaseId)
      .findAll();
  return students.isNotEmpty ? students.first.supabaseId : null;
});