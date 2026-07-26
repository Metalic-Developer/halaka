import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String supabaseId;

  late String email;
  late String fullName;

  @Index()
  late String role;

  @Index()
  String? groupSupabaseId;

  String? mosqueSupabaseId;
  DateTime? createdAt;
}