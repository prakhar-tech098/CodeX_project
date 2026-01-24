import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// --- For Export Functionality ---
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

// ENUM to manage session statuses in a type-safe way
enum SessionStatus { planned, completed, postponed, cancelled }

// DATA MODEL for a single session
class Session {
  String id;
  String title;
  String description;
  TimeOfDay startTime;
  TimeOfDay endTime;
  SessionStatus status;

  Session({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.status = SessionStatus.planned,
  });
}

class SessionPlanScreen extends StatefulWidget {
  const SessionPlanScreen({super.key});

  @override
  _SessionPlanScreenState createState() => _SessionPlanScreenState();
}

class _SessionPlanScreenState extends State<SessionPlanScreen> {
  // --- STATE MANAGEMENT ---
  late final ValueNotifier<List<Session>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Manual Dummy Data - a Map where the key is the date
  final Map<DateTime, List<Session>> _sessions = {
    DateTime.utc(2025, 9, 10): [
      Session(id: '1', title: 'Introduction to AI', description: 'History and basic concepts.', startTime: const TimeOfDay(hour: 10, minute: 0), endTime: const TimeOfDay(hour: 11, minute: 0), status: SessionStatus.completed),
      Session(id: '2', title: 'Machine Learning Basics', description: 'Supervised vs. Unsupervised.', startTime: const TimeOfDay(hour: 14, minute: 0), endTime: const TimeOfDay(hour: 15, minute: 0), status: SessionStatus.completed),
    ],
    DateTime.utc(2025, 9, 12): [
      Session(id: '3', title: 'Linear Regression', description: 'Core concepts and implementation.', startTime: const TimeOfDay(hour: 10, minute: 0), endTime: const TimeOfDay(hour: 11, minute: 0), status: SessionStatus.completed),
    ],
    DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
      Session(id: '4', title: 'Neural Networks', description: 'Introduction to perceptrons.', startTime: const TimeOfDay(hour: 10, minute: 0), endTime: const TimeOfDay(hour: 11, minute: 0)),
      Session(id: '5', title: 'Deep Learning Frameworks', description: 'Overview of TensorFlow and PyTorch.', startTime: const TimeOfDay(hour: 14, minute: 0), endTime: const TimeOfDay(hour: 15, minute: 0), status: SessionStatus.postponed),
    ],
    DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2): [
      Session(id: '6', title: 'Project Discussion', description: 'Brainstorming session for final project.', startTime: const TimeOfDay(hour: 11, minute: 0), endTime: const TimeOfDay(hour: 12, minute: 30)),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Session> _getEventsForDay(DateTime day) {
    // Implementation for getting events for a given day
    return _sessions[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark theme background
      appBar: AppBar(
        title: const Text("Academic Session Planner"),
          backgroundColor: Colors.blue  ,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: _showExportDialog,
            tooltip: 'Export Plan',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Session>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text(
                      "No sessions planned for this day.",
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return _SessionListItem(session: value[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement Add Session logic
        },
        backgroundColor: const Color(0xFF0F3460),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildTableCalendar() {
    return TableCalendar<Session>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      eventLoader: _getEventsForDay,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: const TextStyle(color: Colors.white),
        weekendTextStyle: const TextStyle(color: Colors.white70),
        todayDecoration: BoxDecoration(
          color: const Color(0xFFE94560).withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFFE94560),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Color(0xFF53BF9D),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
      ),
    );
  }

  // --- EXPORT LOGIC ---
  void _showExportDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Export Session Plan"),
          content: const Text("Choose a format to export the complete session plan."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("PDF"),
              onPressed: () {
                Navigator.pop(context);
                _exportToPdf();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.table_chart),
              label: const Text("Excel"),
              onPressed: () {
                Navigator.pop(context);
                _exportToExcel();
              },
            ),
          ],
        ));
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    final sortedDates = _sessions.keys.toList()..sort();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text("Academic Session Plan", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20))),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Date', 'Time', 'Title', 'Description', 'Status'],
            data: sortedDates.expand((date) {
              return _sessions[date]!.map((session) => [
                DateFormat('dd-MM-yyyy').format(date),
                '${session.startTime.format(this.context)} - ${session.endTime.format(this.context)}',
                session.title,
                session.description,
                session.status.toString().split('.').last,
              ]);
            }).toList(),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/session_plan.pdf");
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF saved to ${file.path}")));
    OpenFile.open(file.path);
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Session Plan'];

    // Headers
    sheetObject.appendRow(['Date', 'Start Time', 'End Time', 'Title', 'Description', 'Status']);

    final sortedDates = _sessions.keys.toList()..sort();
    for (var date in sortedDates) {
      for (var session in _sessions[date]!) {
        sheetObject.appendRow([
          DateFormat('dd-MM-yyyy').format(date),
          session.startTime.format(context),
          session.endTime.format(context),
          session.title,
          session.description,
          session.status.toString().split('.').last,
        ]);
      }
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/session_plan.xlsx");
    await file.writeAsBytes(excel.save()!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Excel saved to ${file.path}")));
    OpenFile.open(file.path);
  }
}

// --- CUSTOM WIDGET for the Session List Item ---
class _SessionListItem extends StatelessWidget {
  final Session session;
  const _SessionListItem({required this.session});

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.completed: return const Color(0xFF50C878); // Emerald Green
      case SessionStatus.postponed: return const Color(0xFFFFBF00); // Amber
      case SessionStatus.cancelled: return const Color(0xFFD2122E); // Crimson Red
      default: return const Color(0xFF00BFFF); // Deep Sky Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12.0),
        // border: Border(left: BorderSide(color: _getStatusColor(), width: 5)),
      ),
      child: ListTile(
        title: Text(session.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${session.startTime.format(context)} - ${session.endTime.format(context)}\n${session.description}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () {
          // TODO: Implement Edit Session Logic
        },
      ),
    );
  }
}
