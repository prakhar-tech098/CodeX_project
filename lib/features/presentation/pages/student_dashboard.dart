import 'package:flutter/material.dart';
import '../../authentication/auth/auth_service.dart';
import '../../authentication/auth/role_section.dart';


class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
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
      body: const Center(
        child: Text(
          'Welcome, Student!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
