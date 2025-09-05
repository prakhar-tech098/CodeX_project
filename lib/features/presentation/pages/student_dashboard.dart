import 'package:flutter/material.dart';
import 'package:sih_timetable/features/presentation/pages/session_plan.dart';
import '../../authentication/auth/auth_service.dart';
import '../../authentication/auth/role_section.dart';

// New: A separate screen for "Session Plan"


class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static const List<Map<String, dynamic>> dashboardItems = [
    {'icon': Icons.account_balance_wallet_outlined, 'title': 'Fees'},
    {'icon': Icons.calendar_today_outlined, 'title': 'Holidays'},
    {'icon': Icons.campaign_outlined, 'title': 'Announcement'},
    {'icon': Icons.book_outlined, 'title': 'Bulletin Board'},
    {'icon': Icons.description_outlined, 'title': 'Syllabus'},
    {'icon': Icons.schedule_outlined, 'title': 'Session Plan'},

    {'icon': Icons.flight_land_outlined, 'title': 'Leave\nApplication'},

    {'icon': Icons.chat_bubble_outline, 'title': 'Lecture\nFeedback'},
  ];

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu, color: Colors.white),
            );
          },
        ),
        title: const Text(
          "Student Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 1,
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       await authService.signOut();
        //       Navigator.pushAndRemoveUntil(
        //         context,
        //         MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        //             (route) => false,
        //       );
        //     },
        //     icon: const CircleAvatar(
        //       backgroundColor: Colors.grey,
        //       child: Icon(
        //         Icons.person,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              DrawerHeader(


                decoration: BoxDecoration(
                  color: Colors.green,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,


                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(height: 7,),

                      Text(
                        'Ish Gupta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),


                      Text(
                        'Course Name: B.Tech CS',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Semester Name: SEM-V',
                        style: TextStyle(color: Colors.white),
                      ),

                    ],
                  ),
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.description_outlined, color: Colors.black54),
                title: const Text('Licenses'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.bug_report, color: Colors.black54),
                title: const Text('Report Bug'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black54),
                title: const Text('Logout'),
                onTap: () async {
                  await authService.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: dashboardItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            return _buildDashboardCard(
              context: context,
              icon: dashboardItems[index]['icon'] as IconData,
              title: dashboardItems[index]['title'] as String,
            );
          },
        ),
      ),
    );
  }

  // A helper method to build each individual dashboard card.
  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    // The InkWell widget makes the card a button, providing a visual ripple effect on tap.
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      shadowColor: Colors.grey,
      child: InkWell(
        onTap: () {
          if (title == 'Session Plan') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SessionPlanScreen()),
            );
          } else {
            _showComingSoonDialog(context);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.lightBlue,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: const Text('This feature is not yet available. Please check back later.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
