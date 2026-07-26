import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_config.dart';
import '../models/user.dart';
import '../services/isar_service.dart';

final managerProvider = Provider<ManagerController>((ref) => ManagerController(ref));

class ManagerController {
  final Ref _ref;
  ManagerController(this._ref);

  Future<void> toggleTeacherRegistration(bool open) async {
    await SupabaseConfig.client.from('app_settings').upsert({
      'key': 'teacher_registration',
      'value': open.toString(),
    });
  }

  Future<void> deleteUser(String userId) async {
    await SupabaseConfig.client.from('users').delete().eq('id', userId);
  }

  Future<String> exportStudentsData() async {
    final isar = await IsarService.isar;
    // استخدام filter للحصول على الطلاب فقط
    final users = await isar.users.filter().roleEqualTo('student').findAll();
    final buffer = StringBuffer('الاسم,البريد,المجموعة,عدد نقاط الأسبوع\n');
    for (var u in users) {
      buffer.write('${u.fullName},${u.email},${u.groupSupabaseId},0\n');
    }
    return buffer.toString();
  }
}