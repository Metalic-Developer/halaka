import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/manager_provider.dart';

final exportLoadingProvider = StateProvider<bool>((ref) => false);

class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(managerProvider);
    final isLoading = ref.watch(exportLoadingProvider);
    final registrationEnabled = ref.watch(teacherRegistrationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة المدير')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    ref.read(exportLoadingProvider.notifier).state = true;
                    try {
                      final csv = await controller.exportStudentsData();
                      if (!context.mounted) return;
                      showDialog(context: context, builder: (_) => AlertDialog(content: Text(csv)));
                    } finally {
                      ref.read(exportLoadingProvider.notifier).state = false;
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('تصدير بيانات الطلاب'),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('فتح تسجيل المعلمين'),
            value: registrationEnabled,
            onChanged: (v) {
              ref.read(teacherRegistrationProvider.notifier).state = v;
              controller.toggleTeacherRegistration(v);
            },
          ),
        ],
      ),
    );
  }
}