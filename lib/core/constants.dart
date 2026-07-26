class AppConstants {
  // مفاتيح Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // أسماء الجداول (لتجنب الأخطاء الإملائية)
  static const String tableMosques = 'mosques';
  static const String tableGroups = 'groups';
  static const String tableUsers = 'users';
  static const String tableStudentProfiles = 'student_profiles';
  static const String tableQuranMeta = 'quran_metadata';
  static const String tableSessions = 'sessions';
  static const String tableSessionParts = 'session_parts';

  // الأيام المخصصة للحلقة
  static const List<int> halaqaDays = [DateTime.saturday, DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday];
}