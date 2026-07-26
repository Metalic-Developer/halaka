import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/student_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const groupId = ''; // ستُستبدل بقيمة حقيقية
    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 6));
    final leaderboardAsync = ref.watch(FutureProvider((ref) => ref.read(studentProvider).getWeeklyLeaderboard(groupId, weekStart)));

    return Scaffold(
      appBar: AppBar(title: const Text('المتصدرون هذا الأسبوع')),
      body: leaderboardAsync.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(item['name']),
              trailing: Text('${item['points']} نقطة'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('خطأ: $err'),
      ),
    );
  }
}