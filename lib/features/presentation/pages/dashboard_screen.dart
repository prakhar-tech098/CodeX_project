import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // A list of data for each dashboard item.
  // Each item has an icon and a title.
  static const List<Map<String, dynamic>> dashboardItems = [
    {'icon': Icons.account_balance_wallet_outlined, 'title': 'Fees'},
    {'icon': Icons.currency_rupee, 'title': 'Miscellaneous\nFee'},
    {'icon': Icons.calendar_today_outlined, 'title': 'Holidays'},
    {'icon': Icons.assignment_outlined, 'title': 'Assignment'},
    {'icon': Icons.campaign_outlined, 'title': 'Announcement'},
    {'icon': Icons.book_outlined, 'title': 'Bulletin Board'},
    {'icon': Icons.person_outline, 'title': 'Student\nAssessment'},
    {'icon': Icons.description_outlined, 'title': 'Syllabus'},
    {'icon': Icons.schedule_outlined, 'title': 'Session Plan'},
    {'icon': Icons.add_to_photos_outlined, 'title': 'Admissions'},
    {'icon': Icons.insert_drive_file_outlined, 'title': 'Document'},
    {'icon': Icons.local_library_outlined, 'title': 'Library'},
    {'icon': Icons.groups_outlined, 'title': 'Attendance'},
    {'icon': Icons.flight_land_outlined, 'title': 'Leave\nApplication'},
    {'icon': Icons.business_center_outlined, 'title': 'Placement'},
    {'icon': Icons.lightbulb_outline, 'title': 'Project'},
    {'icon': Icons.edit_note_outlined, 'title': 'Exam'},
    {'icon': Icons.chat_bubble_outline, 'title': 'Lecture\nFeedback'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Changed background to a lighter color
      appBar: AppBar(
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
        backgroundColor: Colors.white,
        elevation: 1, // Add a slight shadow to the app bar
        actions: [
          IconButton(
            onPressed: () {},
            icon: const CircleAvatar(
              // Placeholder for a user profile image.
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.lightBlue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'User Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ...dashboardItems.map((item) {
              return ListTile(
                leading: Icon(item['icon'] as IconData, color: Colors.black54),
                title: Text(item['title'] as String),
                onTap: () {
                  // Handle navigation for each item here
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black54),
              title: const Text('Logout'),
              onTap: () {
                // Handle logout logic
                Navigator.pop(context);
              },
            ),
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
            childAspectRatio: 0.8, // Adjust to control card height.
          ),
          itemBuilder: (context, index) {
            return _buildDashboardCard(
              icon: dashboardItems[index]['icon'] as IconData,
              title: dashboardItems[index]['title'] as String,
            );
          },
        ),
      ),
    );
  }

  // A helper method to build each individual dashboard card.
  Widget _buildDashboardCard({required IconData icon, required String title}) {
    // The InkWell widget makes the card a button, providing a visual ripple effect on tap.
    return Card(
      color: Colors.white, // Changed card color to white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5, // Added elevation for the shadow effect
      shadowColor: Colors.grey, // Customizing shadow color
      child: InkWell(
        onTap: () {
          // Handle tap event for each item.
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.lightBlue, // Light blue color for the icons.
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87, // Darkened text for better contrast
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}