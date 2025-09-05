import 'package:flutter/material.dart';

class SessionPlanScreen extends StatelessWidget {
  const SessionPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Session Plan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A simple calendar view using a GridView.
            const Text(
              'September 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: 30, // Assuming 30 days in the month
              itemBuilder: (context, index) {
                final day = index + 1;
                final isSelected = day == 5; // Highlight the 5th for a demonstration

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.lightBlue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Upcoming Sessions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // A list of sessions for the selected day
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                SessionItem(
                  title: 'Introduction to Calculus',
                  teacher: 'Prof. John Doe',
                  time: '10:00 AM - 11:00 AM',
                ),
                SessionItem(
                  title: 'History of the Mughal Empire',
                  teacher: 'Dr. Jane Smith',
                  time: '1:00 PM - 2:00 PM',
                ),
                SessionItem(
                  title: 'Organic Chemistry Lab',
                  teacher: 'Dr. Emily White',
                  time: '3:00 PM - 4:00 PM',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A simple widget for a single session item
class SessionItem extends StatelessWidget {
  final String title;
  final String teacher;
  final String time;

  const SessionItem({
    super.key,
    required this.title,
    required this.teacher,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Teacher: $teacher',
              style: const TextStyle(color: Colors.black54),
            ),
            Text(
              'Time: $time',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
