// lib/data/timetable_service.dart
import 'package:mongo_dart/mongo_dart.dart';

class TimetableService {
  // NOTE: test-only – don’t ship credentials in the app
  static const String _uri =
      "mongodb+srv://porwalsuryansh92:faVRYRZJ37SR6ks9@socibot.8io8w.mongodb.net/timetableDB?retryWrites=true&w=majority";

  Future<List<Map<String, dynamic>>> getTimetableForTeacher(String teacherId) async {
    final db = await Db.create(_uri);
    await db.open();
    final coll = db.collection('timetables');

    // query for this teacher (adapt field if your DB uses different key)
    final result = await coll.find().toList();

    await db.close();
    return result;
  }
}
