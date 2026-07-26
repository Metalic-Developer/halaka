import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_config.dart';
import '../models/user.dart';
import '../services/isar_service.dart';

final managerProvider = Provider<ManagerController>((ref) => ManagerController(ref));

class ManagerController {
  final Ref _ref;
  ManagerController(this._ref);

  /// فتح/إغلاق تسجيل المعلمين (تعديل في جدول إعدادات، نفترض وجود جدول app_settings)
  Future<void> toggleTeacherRegistration(bool open) async {
    // نستخدم جدول خاص أو متغير في Supabase
    await SupabaseConfig.client.from('app_settings').upsert({
      'key': 'teacher_registration',
      'value': open.toString(),
    });
  }

  /// حذف مستخدم (حذف من auth ومن public.users)
  Future<void> deleteUser(String userId) async {
    // حذف من public.users (سياسة RLS تسمح للمدير فقط)
    await SupabaseConfig.client.from('users').delete().eq('id', userId);
    // لا يمكن حذف من auth عبر العميل العادي، سنقوم بذلك عبر دالة serverless أو Edge Function
    // سنكتفي بالحذف من الجدول العام حالياً، مع الأخذ بالاعتبار صلاحية المستخدم.
  }

  /// تصدير بيانات (CSV)
  Future<String> exportStudentsData() async {
    // جلب البيانات من Isar (أو Supabase) وتنسيقها CSV
    final isar = await IsarService.isar;
    final users = await isar.users.where().roleEqualTo('student').findAll();
    final buffer = StringBuffer('الاسم,البريد,المجموعة,عدد نقاط الأسبوع\n');
    for (var u in users) {
      // يمكن إضافة المزيد من التفاصيل
      buffer.write('${u.fullName},${u.email},${u.groupSupabaseId},0\n');
    }
    return buffer.toString();
  }
}