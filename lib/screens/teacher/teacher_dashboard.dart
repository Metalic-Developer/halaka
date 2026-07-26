import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../providers/auth_provider.dart';
import 'day_session_list.dart';
import 'package:intl/intl.dart';

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - DateTime.saturday));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.signOut()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // زر حلقة اليوم
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DaySessionList()),
                  );
                },
                icon: const Icon(Icons.menu_book, size: 30),
                label: Text(
                  '${AppStrings.todaySession} - ${DateFormat.yMMMMd('ar').format(today)}',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // جدول الأسبوع (يمكن أن يكون جداول اختيارية)
            Text('الأسبوع: ${DateFormat.yMMMd('ar').format(weekStart)}'),
            // ... عرض سريع لأيام الأسبوع
          ],
        ),
      ),
    );
  }
}