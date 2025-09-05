import 'package:flutter/material.dart';
import 'dart:math';

// ENUM to manage session statuses in a type-safe way
enum SessionStatus { planned, completed, postponed, cancelled }

// DATA MODEL for a single session
class Session {
  final String id;
  final String title;
  final DateTime date;
  SessionStatus status;

  Session({
    required this.id,
    required this.title,
    required this.date,
    this.status = SessionStatus.planned,
  });
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // MANUAL DUMMY DATA - This will be replaced by your Firebase data later
  final List<Session> _sessions = [
    Session(id: '1', title: 'Computer Network', date: DateTime(2025, 9, 10)),
    Session(id: '2', title: 'Introduction to AI', date: DateTime(2025, 9, 12)),
    Session(id: '3', title: 'Advance Java', date: DateTime(2025, 9, 15), status: SessionStatus.completed),
    Session(id: '4', title: 'Python', date: DateTime(2025, 9, 17), status: SessionStatus.completed),
    Session(id: '5', title: 'Theory of automata', date: DateTime(2025, 9, 19)),
    Session(id: '6', title: 'Data Science', date: DateTime(2025, 9, 22), status: SessionStatus.postponed),
    Session(id: '7', title: 'Guest Lecture on Cryogenics', date: DateTime(2025, 9, 3), status: SessionStatus.cancelled),
    Session(id: '8', title: 'Gibbs Free Energy', date: DateTime(2025, 9, 24)),
    Session(id: '9', title: 'Maxwell Relations', date: DateTime(2025, 9, 26), status: SessionStatus.completed),
    Session(id: '10', title: 'Final Project Discussion', date: DateTime(2025, 9, 29)),
  ];

  // --- Real-time Update Logic ---

  void _updateSessionStatus(String id, SessionStatus newStatus) {
    setState(() {
      final session = _sessions.firstWhere((s) => s.id == id);
      session.status = newStatus;
    });
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    // Filter sessions into different lists
    final upcoming = _sessions.where((s) => s.status == SessionStatus.planned).toList();
    final completed = _sessions.where((s) => s.status == SessionStatus.completed).toList();
    final others = _sessions.where((s) => s.status == SessionStatus.postponed || s.status == SessionStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text("Progress Indicator"),
        centerTitle: true,
        // You can dynamically set the course info here
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'B.Tech CS - Semester V',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProgressOverview(),
              const SizedBox(height: 24),
              _buildSessionList('Upcoming Classes', upcoming, const Color(0xFF4A90E2)),
              _buildSessionList('Completed Classes', completed, const Color(0xFF50E3C2)),
              _buildSessionList('Postponed / Cancelled', others, const Color(0xFF9B9B9B)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement logic to add a new session
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add New Session Tapped!')),
          );
        },
        backgroundColor: const Color(0xFF3A7BD5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProgressOverview() {
    final trackableSessions = _sessions.where((s) => s.status != SessionStatus.cancelled).length;
    final completedSessions = _sessions.where((s) => s.status == SessionStatus.completed).length;
    final progress = trackableSessions > 0 ? completedSessions / trackableSessions : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ShaderMask(
                  shaderCallback: (rect) {
                    return const SweepGradient(
                      startAngle: 0.0,
                      endAngle: 2 * pi,
                      stops: [0.0, 1.0],
                      colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
                    ).createShader(rect);
                  },
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3A7BD5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Course Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedSessions of $trackableSessions Sessions Completed',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(String title, List<Session> sessions, Color headerColor) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headerColor),
          ),
        ),
        ...sessions.map((session) => _SessionCard(
          session: session,
          onMarkCompleted: () => _updateSessionStatus(session.id, SessionStatus.completed),
          onMarkCancelled: () => _updateSessionStatus(session.id, SessionStatus.cancelled),
        )).toList(),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback onMarkCompleted;
  final VoidCallback onMarkCancelled;

  const _SessionCard({
    required this.session,
    required this.onMarkCompleted,
    required this.onMarkCancelled,
  });

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed: return Colors.green;
      case SessionStatus.postponed: return Colors.orange;
      case SessionStatus.cancelled: return Colors.red;
      case SessionStatus.planned:
      default: return Colors.blue;
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed: return 'Completed';
      case SessionStatus.postponed: return 'Postponed';
      case SessionStatus.cancelled: return 'Cancelled';
      case SessionStatus.planned:
      default: return 'Planned';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(session.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(session.status),
                    style: TextStyle(color: _getStatusColor(session.status), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${session.date.day}/${session.date.month}/${session.date.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                  label: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                  onPressed: onMarkCancelled,
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  label: const Text('Complete', style: TextStyle(color: Colors.white)),
                  onPressed: onMarkCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}