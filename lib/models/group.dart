import 'package:isar/isar.dart';

part 'group.g.dart';

@collection
class Group {
  Id id = Isar.autoIncrement;
  late String supabaseId;
  late String mosqueSupabaseId; // العلاقة بالمسجد عبر uuid
  late String name;
  DateTime? createdAt;
}