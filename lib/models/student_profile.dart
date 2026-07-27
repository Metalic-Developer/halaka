import 'package:isar/isar.dart';

part 'student_profile.g.dart';

@collection
class StudentProfile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userSupabaseId;

  // ✅ الحقل الجديد لربط ولي الأمر
  @Index()
  String? guardianSupabaseId;

  late int newPagesTarget;
  late int reviewPagesTarget;
  DateTime? updatedAt;
}