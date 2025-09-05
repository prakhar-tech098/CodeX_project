import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sih_timetable/features/presentation/pages/splash.dart';
import 'package:sih_timetable/features/presentation/pages/student_dashboard.dart';
import 'package:sih_timetable/features/presentation/pages/teacher_dashboard.dart';

// Make sure you have a firebase_options.dart file from flutterfire configure
import 'features/authentication/auth/role_section.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TeacherDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
