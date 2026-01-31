import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/models/tescherTimetable_entry.dart';
import '../../../core/models/timetable_entry.dart';

class TimetableService {
  final String baseUrl = 'http://10.0.2.2:8000';

  // Note: In production, retrieve this token dynamically from secure storage.
  final String _token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBleGFtcGxlLmNvbSIsImV4cCI6MTc2OTg2MDg3M30.BlgNxa1b9Ou7TZ9PiuFP1B0XWMX_Urt2NPGuZ7eo5nU';

  // --- STUDENT HELPERS (Unchanged) ---

  int _branchNameToId(String branch) {
    switch (branch.toUpperCase()) {
      case 'CSE': return 1;
      case 'ECE': return 2;
      case 'ME':  return 3;
      case 'CE':  return 4;
      default: throw Exception("Unknown branch: $branch");
    }
  }

  // --- SERVICE METHODS ---

  // ✅ STUDENT: Fetch timetable for their branch (Unchanged logic)
  // ---------------- STUDENT ----------------
  Future<List<TimetableEntry>> fetchStudentTimetable(String branchName) async {
    final branchId = _branchNameToId(branchName);
    final url = Uri.parse('$baseUrl/timetable/branch/$branchId');

    final response = await http.get(url);

    final List data = jsonDecode(response.body);
    return data.map((e) => TimetableEntry.fromJson(e)).toList();
  }

// ---------------- TEACHER ----------------
  Future<List<TeacherTimetableEntry>> fetchTeacherTimetableByName(
      String teacherName,
      ) async {
    final url = Uri.parse(
      '$baseUrl/timetable/teacher/${Uri.encodeComponent(teacherName)}',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => TeacherTimetableEntry.fromJson(e)).toList();
  }}
