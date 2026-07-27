import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_config.dart';
import '../models/user.dart';
import '../models/session.dart';
import '../services/isar_service.dart';

final managerProvider = Provider<ManagerController>((ref) => ManagerController(ref));

class ManagerController {
  final Ref _ref;
  ManagerController(this._ref);

  Future<bool> getTeacherRegistrationStatus() async {
    try {
      final res = await SupabaseConfig.client
          .from('app_settings')
          .select('value')
          .eq('key', 'teacher_registration_open')
          .maybeSingle();
      return res != null && res['value'] == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleTeacherRegistration(bool open) async {
    await SupabaseConfig.client.from('app_settings').upsert({
      'key': 'teacher_registration_open',
      'value': open.toString(),
    });
  }

  Future<void> deleteUser(String userId) async {
    await SupabaseConfig.client.from('users').delete().eq('id', userId);
  }

  Future<String> exportStudentsData() async {
    final isar = await IsarService.isar;
    final users = await isar.users.filter().roleEqualTo('student').findAll();
    final buffer = StringBuffer('الاسم,البريد,المجموعة,إجمالي نقاط التسميع\n');

    for (var u in users) {
      final sessions = await isar.sessions
          .filter()
          .studentSupabaseIdEqualTo(u.supabaseId)
          .findAll();
      final totalPoints = sessions.fold<double>(0, (sum, s) => sum + s.totalPoints);
      buffer.write('${u.fullName},${u.email},${u.groupSupabaseId},$totalPoints\n');
    }
    return buffer.toString();
  }
}