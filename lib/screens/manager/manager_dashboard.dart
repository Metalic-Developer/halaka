import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/manager_provider.dart';

class ManagerDashboard extends ConsumerWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(managerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة المدير')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () async {
              final csv = await controller.exportStudentsData();
              // عرض أو مشاركة الملف
              showDialog(context: context, builder: (_) => AlertDialog(content: Text(csv)));
            },
            child: const Text('تصدير بيانات الطلاب'),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('فتح تسجيل المعلمين'),
            value: false, // يجب جلب الحالة من Supabase
            onChanged: (v) => controller.toggleTeacherRegistration(v),
          ),
          // ... قوائم حذف المستخدمين إلخ
        ],
      ),
    );
  }
}