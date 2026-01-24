import 'package:flutter/material.dart';


import '../../authentication/auth/auth_service.dart'; // Adjust this import path if needed

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Use a Future variable to prevent re-fetching on every widget rebuild
  late final Future<Map<String, dynamic>?> _userDetailsFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Fetch the user details only once when the screen is initialized
    _userDetailsFuture = _authService.getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Light background
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: const Color(0xFF16213E), // Dark blue app bar
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userDetailsFuture,
        builder: (context, snapshot) {
          // --- LOADING STATE ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- ERROR STATE ---
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Could not load profile data.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // --- SUCCESS STATE ---
          final userData = snapshot.data!;
          final role = userData['role'] ?? 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(userData),
                const SizedBox(height: 24),
                // Dynamically build the rest of the profile based on the user's role
                if (role == 'student')
                  _buildStudentInfo(userData)
                else if (role == 'teacher')
                  _buildTeacherInfo(userData)
                else
                  const Text('User role could not be determined.'),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final String name = userData['name'] ?? 'No Name';
    final String email = userData['email'] ?? 'No Email';
    final String role = (userData['role'] ?? 'user').toUpperCase();

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF0F3460),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(fontSize: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(role),
          backgroundColor: const Color(0xFFE94560).withOpacity(0.8),
          labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // --- ROLE-SPECIFIC INFO CARDS ---

  Widget _buildStudentInfo(Map<String, dynamic> userData) {
    return Column(
      children: [
        _buildInfoCard(
          title: 'Academic Information',
          icon: Icons.school,
          details: {
            'Student ID': userData['studentId'] ?? 'N/A',
            'Branch': userData['branch'] ?? 'N/A',
            'Semester': userData['semester']?.toString() ?? 'N/A',
            'Enrollment Year': userData['enrollmentYear']?.toString() ?? 'N/A',
          },
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Contact Information',
          icon: Icons.contact_mail,
          details: {
            'Phone Number': userData['phone'] ?? 'N/A',
          },
        ),
      ],
    );
  }

  Widget _buildTeacherInfo(Map<String, dynamic> userData) {
    return Column(
      children: [
        _buildInfoCard(
          title: 'Professional Information',
          icon: Icons.work,
          details: {
            'Employee ID': userData['employeeId'] ?? 'N/A',
            'Department': userData['department'] ?? 'N/A',
            'Subjects Taught': (userData['subjects'] as List<dynamic>?)?.join(', ') ?? 'N/A',
            'Office Location': userData['office'] ?? 'N/A',
          },
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Contact Information',
          icon: Icons.contact_mail,
          details: {
            'Phone Number': userData['phone'] ?? 'N/A',
          },
        ),
      ],
    );
  }

  // Reusable card widget for displaying information
  Widget _buildInfoCard({required String title, required IconData icon, required Map<String, String> details}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF16213E)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...details.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(color: Colors.grey)),
                  Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
