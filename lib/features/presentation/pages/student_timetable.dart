import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/models/timetable_entry.dart';
import '../../authentication/auth/timetable_service.dart';

class StudentTimetableScreen extends StatefulWidget {
  const StudentTimetableScreen({super.key});

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen> {
  Future<List<TimetableEntry>>? timetableFuture;
  String? studentBranch;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserAndTimetable();
  }

  // Fetches User Branch first, then the Timetable
  Future<void> _loadUserAndTimetable() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        final branch = data['branch'] as String?;

        if (branch != null) {
          setState(() {
            studentBranch = branch;
            timetableFuture = TimetableService().fetchStudentTimetable(branch);
            isLoading = false;
          });
        } else {
          throw Exception("Branch field not found for this user.");
        }
      } else {
        throw Exception("User profile not found in database.");
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(studentBranch != null ? '$studentBranch Timetable' : 'Timetable'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return FutureBuilder<List<TimetableEntry>>(
      future: timetableFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final timetable = snapshot.data ?? [];

        if (timetable.isEmpty) {
          return const Center(child: Text("No timetable entries found."));
        }

        return _buildTimetableGrid(timetable);
      },
    );
  }

  // --- Grid View Builder Methods ---

  Widget _buildTimetableGrid(List<TimetableEntry> timetable) {
    final days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'];
    final periods = [1, 2, 3, 4, 5, 6];

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(120.0),
            border: TableBorder.all(color: Colors.grey.shade300, width: 1),
            children: [
              // Header Row
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF16213E)),
                children: [
                  _buildHeaderCell('SLOT'),
                  ...days.map((day) => _buildHeaderCell(day)).toList(),
                ],
              ),
              // Data Rows (Periods)
              ...periods.map((period) {
                return TableRow(
                  children: [
                    _buildSlotCell('P$period'),
                    ...days.map((day) {
                      final entry = timetable.firstWhere(
                            (e) => e.period == period && e.day.toUpperCase() == day,
                        orElse: () => TimetableEntry(
                          period: period,
                          day: day,
                          subjectName: '',
                          teacherName: '',
                          roomName: '',
                        ),
                      );
                      return _buildDataCell(entry);
                    }).toList(),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSlotCell(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildDataCell(TimetableEntry entry) {
    if (entry.subjectName.isEmpty) {
      return Container(height: 100);
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            entry.subjectName,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            entry.teacherName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entry.roomName,
              style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}