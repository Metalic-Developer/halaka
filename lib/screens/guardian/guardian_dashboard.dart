import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/teacher_provider.dart';
import '../../models/session.dart';

class GuardianDashboard extends ConsumerWidget {
  const GuardianDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Center(child: CircularProgressIndicator());

    const studentId = ''; // ستربط لاحقًا

    final sessionsAsync = ref.watch(FutureProvider((ref) =>
        ref.read(teacherProvider).getStudentWeeklySessions(studentId, DateTime.now())));

    return Scaffold(
      appBar: AppBar(title: const Text('متابعة الطالب')),
      body: sessionsAsync.when(
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
        loading: () => const CircularProgressIndicator(),
        error: (err, _) => Text('خطأ: $err'),
      ),
    );
  }
}