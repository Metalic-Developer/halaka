import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/mosque.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../models/student_profile.dart';
import '../models/session.dart';
import '../models/session_part.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> get isar async {
    if (_isar == null || !_isar!.isOpen) {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [
          MosqueSchema,
          GroupSchema,
          UserSchema,
          StudentProfileSchema,
          SessionSchema,
          SessionPartSchema,
        ],
        directory: dir.path,
      );
    }
    return _isar!;
  }
}