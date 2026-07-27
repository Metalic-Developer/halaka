import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../models/session.dart';
import '../../services/isar_service.dart';
import '../../utils/helpers.dart';

final studentSessionsProvider = FutureProvider.family<List<Session>, ({String studentId, DateTime weekStart})>(
  (ref, params) {
    return ref.read(teacherProvider).getStudentWeeklySessions(params.studentId, params.weekStart);
  },
);

class GuardianDashboard extends ConsumerWidget {
  const GuardianDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    if (currentUser == null) return const Center(child: CircularProgressIndicator());

    final studentIdAsync = ref.watch(guardianStudentIdProvider(currentUser.supabaseId));

    return Scaffold(
      appBar: AppBar(title: const Text('متابعة الطالب')),
      body: studentIdAsync.when(
        data: (studentId) {
          if (studentId == null) return const Center(child: Text('لا يوجد طالب مرتبط بهذا الحساب'));
          final weekStart = Helpers.getWeekStart(DateTime.now());
          final sessionsAsync = ref.watch(studentSessionsProvider((studentId: studentId, weekStart: weekStart)));
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

// ✅ الربط الحقيقي عن طريق guardianSupabaseId
final guardianStudentIdProvider = FutureProvider.family<String?, String>((ref, guardianSupabaseId) async {
  final isar = await IsarService.isar;
  final profile = await isar.studentProfiles.filter()
      .guardianSupabaseIdEqualTo(guardianSupabaseId)
      .findFirst();
  return profile?.userSupabaseId;
});