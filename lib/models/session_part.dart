import 'package:isar/isar.dart';

part 'session_part.g.dart';

enum SessionType {
  memorization,
  cumulative,
  review,
}

@collection
class SessionPart {
  Id id = Isar.autoIncrement;

  @Index()
  late int sessionLocalId;

  @Index(unique: true, replace: true)
  String? supabaseId;

  @enumerated
  late SessionType type;

  late int suraStart;
  late int ayaStart;
  late int suraEnd;
  late int ayaEnd;
  double pagesCount = 0;
  bool isExtra = false;         // إذا true يكون إضافيًا
  String? evaluation;
  String? notes;

  @Index()
  bool isSynced = false;
}