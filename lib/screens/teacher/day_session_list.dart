import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../widgets/student_card.dart';
import 'session_form.dart';

final groupStudentsProvider = FutureProvider.family<List<User>, String>((ref, groupId) {
  return ref.read(teacherProvider).getGroupStudents(groupId);
});

class DaySessionList extends ConsumerWidget {
  const DaySessionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teacher = ref.watch(authStateProvider).value;
    final groupId = teacher?.groupSupabaseId ?? '';

    final studentsAsync = ref.watch(groupStudentsProvider(groupId));

    return Scaffold(
      appBar: AppBar(title: const Text('حلقة اليوم - قائمة الطلاب')),
      body: studentsAsync.when(
        data: (students) {
          final isWide = MediaQuery.of(context).size.width > 600;
          if (isWide) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: students.length,
              itemBuilder: (context, index) => _buildStudentCard(context, students[index]),
            );
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) => _buildStudentCard(context, students[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, User student) {
    return StudentCard(
      student: student,
      attendancePercent: _calculateAttendance(student),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionForm(student: student),
          ),
        );
      },
    );
  }

  double _calculateAttendance(User student) {
    // ستُستبدل بالحساب الحقيقي من Isar
    return 100.0;
  }
}