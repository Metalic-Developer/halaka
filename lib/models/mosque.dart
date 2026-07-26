import 'package:isar/isar.dart';

part 'mosque.g.dart'; // سيتم إنشاؤه بواسطة build_runner

@collection
class Mosque {
  Id id = Isar.autoIncrement; // رقم محلي للتعامل مع Isar
  late String supabaseId; // uuid من Supabase
  late String name;
  DateTime? createdAt;
}