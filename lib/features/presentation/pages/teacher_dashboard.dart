import 'package:flutter/material.dart';
import '../../authentication/auth/auth_service.dart';
import '../../authentication/auth/role_section.dart';


class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
          'Welcome, Teacher!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
