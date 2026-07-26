import 'package:isar/isar.dart';

part 'mosque.g.dart';

@collection
class Mosque {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String supabaseId;

  late String name;
  DateTime? createdAt;
}