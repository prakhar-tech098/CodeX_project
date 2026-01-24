import 'package:flutter/material.dart';
import '../../authentication/auth/timetable_service.dart';

class TimeTableScreen extends StatefulWidget {
  final String userId;
  final String userRole;

  const TimeTableScreen({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.delayed(
      const Duration(seconds: 5),
          () => TimetableService().getTimetableForTeacher(widget.userId),
    ).then((f) => f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Timetable'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('No timetable found.'));
          }
          return _buildTimeTable(snap.data!);
        },
      ),
    );
  }

  Widget _buildTimeTable(List<Map<String, dynamic>> docs) {
    /// Display columns as time slots
    final timeSlots = [
      '9:10 – 10:00',
      '10:10 – 11:00',
      '11:10 – 12:00',
      '12:00 – 01:00 (Lunch)',
      '01:10 – 02:00',
      '02:10 – 03:00',
    ];

    /// Display rows as days
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    /// Build quick lookup by "day_slot"
    final Map<String, Map<String, dynamic>> cellMap = {};
    for (var d in docs) {
      final key = '${d['day']}_${d['slot']}';
      cellMap[key] = d;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: DataTable(
            headingRowColor: MaterialStateProperty.resolveWith(
                  (_) => Colors.orange[200]!,
            ),
            dataRowHeight: 80,
            columnSpacing: 18,
            columns: [
              const DataColumn(
                label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...timeSlots.map(
                    (slot) => DataColumn(
                  label: Text(
                    slot,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            rows: days.map((day) {
              return DataRow(
                cells: [
                  DataCell(Text(day)),
                  ...List.generate(timeSlots.length, (index) {
                    // Slot numbering: 1,2,3 then skip lunch then 4,5 after lunch
                    if (index == 3) {
                      return DataCell(
                        Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text(
                            'LUNCH',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }

                    // adjust for DB slot after lunch
                    final slotNumber = index >= 3 ? index : index + 1;
                    final key = '${day}_$slotNumber';
                    final cell = cellMap[key];

                    if (cell == null) return const DataCell(Text(''));

                    return DataCell(
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cell['course'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cell['faculty_name'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            if (cell['room'] != null)
                              Text(
                                cell['room'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
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
