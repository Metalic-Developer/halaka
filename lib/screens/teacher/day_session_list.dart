import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../../models/user.dart';
import '../../widgets/student_card.dart';
import 'session_form.dart';

class DaySessionList extends ConsumerWidget {
  const DaySessionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const groupId = 'some-group-uuid'; // ستجلب لاحقًا من بيانات المعلم
    // ✅ استخدام FutureProvider مباشرة
    final studentsAsync = ref.watch(FutureProvider((ref) => ref.read(teacherProvider).getGroupStudents(groupId)));

    return Scaffold(
      appBar: AppBar(title: const Text('حلقة اليوم - قائمة الطلاب')),
      body: studentsAsync.when(
        data: (students) => ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return StudentCard(
              student: student,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionForm(student: student),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}