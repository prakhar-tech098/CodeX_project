import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sih_timetable/features/presentation/pages/progress_screen.dart';
import 'package:sih_timetable/features/presentation/pages/session_plan.dart';
import 'package:sih_timetable/features/presentation/pages/profile_screen.dart';
import 'package:sih_timetable/features/presentation/pages/timetable.dart';

import '../../authentication/auth/auth_service.dart';
import '../../authentication/auth/role_section.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  // Updated the list to include a 'Timetable' option
  static const List<Map<String, dynamic>> dashboardItems = [
    {'icon': Icons.account_balance_wallet_outlined, 'title': 'Fees'},
    {'icon': Icons.calendar_today_outlined, 'title': 'Holidays'},
    {'icon': Icons.campaign_outlined, 'title': 'Announcement'},
    {'icon': Icons.table_chart_outlined, 'title': 'Timetable'}, // ADDED
    {'icon': Icons.description_outlined, 'title': 'Syllabus'},
    {'icon': Icons.schedule_outlined, 'title': 'Session Plan'},
    {'icon': Icons.group_work, 'title': 'Progress Indicator'},
    {'icon': Icons.flight_land_outlined, 'title': 'Leave\nApplication'},
    {'icon': Icons.chat_bubble_outline, 'title': 'Lecture\nFeedback'},
  ];

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu, color: Colors.black),
            );
          },
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 1,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: authService.getUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return UserAccountsDrawerHeader(
                    accountName: const Text("Loading..."),
                    accountEmail: Text(currentUser?.email ?? "Loading email..."),
                    currentAccountPicture: const CircleAvatar(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    decoration: const BoxDecoration(color: Color(0xFF16213E)),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return UserAccountsDrawerHeader(
                    accountName: const Text("User Not Found"),
                    accountEmail: Text(currentUser?.email ?? "No email"),
                    currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
                    decoration: const BoxDecoration(color: Color(0xFF16213E)),
                  );
                }
                final userData = snapshot.data!;
                final userName = userData['name'] ?? 'No Name Provided';
                final userEmail = userData['email'] ?? 'No Email Provided';
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    userName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: const Color(0xFFE94560),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40.0, color: Colors.white),
                    ),
                  ),
                  decoration: const BoxDecoration(color: Color(0xFF16213E)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
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
            const SizedBox(height: 10),
          ],
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
              authService: authService, // Pass the authService instance
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required AuthService authService, // Receive the authService
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: InkWell(
        onTap: () async { // Make onTap async to handle data fetching
          if (title == 'Session Plan') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SessionPlanScreen()),
            );
          } else if (title == 'Progress Indicator') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProgressScreen()),
            );
          } else if (title == 'Timetable') {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            try {
              final userDetails = await authService.getUserDetails();
              Navigator.pop(context);

              if (userDetails != null) {
                final userRole = (userDetails['role'] ?? '').toString().toLowerCase();
                final uid = userDetails['uid'];          // use uid directly

                if (userRole == 'teacher') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TimeTableScreen(
                        userId: uid,                      // pass uid
                        userRole: userRole,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Role is not teacher.')));
                }
              }
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }


          else {
            _showComingSoonDialog(context);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.lightBlue),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
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
          content: const Text('This feature is not yet available.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
