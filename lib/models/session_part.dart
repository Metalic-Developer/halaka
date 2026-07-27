import 'package:isar/isar.dart';

part 'session_part.g.dart';

enum SessionType {
  memorization,
  cumulative,
  review,
  unknown,
}

extension SessionTypeMapper on SessionType {
  String toDatabase() {
    switch (this) {
      case SessionType.memorization:
        return 'memorization';
      case SessionType.cumulative:
        return 'cumulative';
      case SessionType.review:
        return 'review';
      case SessionType.unknown:
        return 'unknown';
    }
  }

  static SessionType fromDatabase(String value) {
    switch (value) {
      case 'memorization':
        return SessionType.memorization;
      case 'cumulative':
        return SessionType.cumulative;
      case 'review':
        return SessionType.review;
      default:
        return SessionType.unknown;
    }
  }
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
  bool isExtra = false;
  String? evaluation;
  String? notes;

  @Index()
  bool isSynced = false;
}