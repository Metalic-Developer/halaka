import 'package:isar/isar.dart';

part 'session_part.g.dart';

@collection
class SessionPart {
  Id id = Isar.autoIncrement;

  @Index()
  late int sessionLocalId;    // نعود إلى int

  @Index(unique: true, replace: true)
  String? supabaseId;

  late String type;
  late int suraStart;
  late int ayaStart;
  late int suraEnd;
  late int ayaEnd;
  double pagesCount = 0;
  bool isExtra = false;
  String? evaluation;
  String? notes;

  @Index()
  bool isSynced = false;
}