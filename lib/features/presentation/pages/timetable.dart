import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/tescherTimetable_entry.dart';
import '../../authentication/auth/timetable_service.dart';
// Import your new separate teacher model


class TeacherTimeTableScreen extends StatefulWidget {
  final String userId;

  const TeacherTimeTableScreen({
    super.key,
    required this.userId,
  });

  @override
  State<TeacherTimeTableScreen> createState() => _TeacherTimeTableScreenState();
}

class _TeacherTimeTableScreenState extends State<TeacherTimeTableScreen> {
  // Use the NEW Teacher model here
  late Future<List<TeacherTimetableEntry>> _timetableFuture;
  String _teacherDisplayName = "Teacher";

  @override
  void initState() {
    super.initState();
    _timetableFuture = _initializeTeacherData();
  }

  Future<List<TeacherTimetableEntry>> _initializeTeacherData() async {
    // 1. Fetch teacher name from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    final name = userDoc.data()?['name'] ?? "";

    if (mounted) {
      setState(() {
        _teacherDisplayName = name;
      });
    }

    // 2. Fetch via the updated service method that returns TeacherTimetableEntry
    return TimetableService().fetchTeacherTimetableByName(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Schedule: $_teacherDisplayName'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<TeacherTimetableEntry>>(
        future: _timetableFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No classes found for your name.'));
          }

          return _buildTimeTable(docs);
        },
      ),
    );
  }

  Widget _buildTimeTable(List<TeacherTimetableEntry> docs) {
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];
    final Map<String, TeacherTimetableEntry> cellMap = {};

    for (var d in docs) {
      final String day = d.day.toUpperCase();
      final int slot = d.period;
      cellMap['${day}_$slot'] = d;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.indigo[50]),
            dataRowMaxHeight: 100,
            border: TableBorder.all(color: Colors.grey.shade300),
            columns: [
              const DataColumn(label: Text('DAY', style: TextStyle(fontWeight: FontWeight.bold))),
              ...List.generate(6, (i) => DataColumn(label: Text('P${i + 1}'))),
            ],
            rows: days.map((day) {
              return DataRow(
                cells: [
                  DataCell(Text(day.substring(0, 3), style: const TextStyle(fontWeight: FontWeight.bold))),
                  ...List.generate(6, (index) {
                    final slotNumber = index + 1;
                    final entry = cellMap['${day}_$slotNumber'];

                    if (entry == null) return const DataCell(Center(child: Text("-")));

                    return DataCell(
                      SizedBox(
                        width: 140,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.subjectName,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                            // This now works because it is defined in TeacherTimetableEntry!
                            Text(
                              "Branch: ${entry.branchName}",
                              style: const TextStyle(fontSize: 11, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(4)
                              ),
                              child: Text(
                                entry.roomName,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}