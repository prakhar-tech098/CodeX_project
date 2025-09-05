import 'package:flutter/material.dart';
import '../../presentation/pages/teacher_dashboard.dart';
import 'auth_service.dart';
import 'teacher_signup.dart';
 // Assuming dashboards folder

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  _TeacherLoginScreenState createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userCredential = await _authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
        context,
      );

      // Check if the widget is still in the tree
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (userCredential != null) {
        final role = await _authService.getUserRole(userCredential.user!.uid);
        if (role == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TeacherDashboard()),
          );
        } else {
          _authService.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not a teacher account.')),
          );
        }
      }
    }
  }

  // NEW: Function to show the forgot password dialog
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    // Pre-fill the email if the user has already typed it
    resetEmailController.text = _emailController.text;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Send Link'),
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                _authService.sendPasswordResetEmail(email, context);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 80, color: Colors.deepPurpleAccent),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                ),
                const SizedBox(height: 10),
                // NEW: Forgot Password Button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 10),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
                TextButton(
                  child: const Text('Need an account? Sign up'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeacherSignUpScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

