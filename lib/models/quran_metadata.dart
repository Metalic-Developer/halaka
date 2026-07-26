import 'package:isar/isar.dart';

part 'quran_metadata.g.dart';

@collection
class QuranMetadata {
  Id id = Isar.autoIncrement;

  @Index()
  late int sora;

  late int ayaNo;

  @Index()
  late int page;

  late int jozz;
  String? soraNameAr;
}