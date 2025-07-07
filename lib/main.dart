import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'screens/auth/login.dart';
import 'screens/announcement.dart';
import 'screens/schedule_programme.dart';
import 'screens/payment.dart';
import 'screens/program_details.dart';
import 'screens/team_members.dart';
import 'widgets/auth_wrapper.dart';
import 'screens/home_page.dart';
import 'screens/auth/signup.dart';
import 'screens/auth/forgot_password.dart';

class AppData extends ChangeNotifier {
  List<String> announcements = [];
  List<Map<String, dynamic>> scheduledPrograms = [];
  Map<String, List<Map<String, String>>> teamMembers = {
    'Idamthala': [],
    'Valamthala': [],
    'Kombu': [],
    'Kuzhalu': [],
    'Ilathaalam': [],
  };

  void addAnnouncement(String announcement) {
    announcements.add(announcement);
    notifyListeners();
  }

  void removeAnnouncement(int index) {
    if (index >= 0 && index < announcements.length) {
      announcements.removeAt(index);
      notifyListeners();
    }
  }

  void addProgram(Map<String, dynamic> program) {
    scheduledPrograms.add(program);
    notifyListeners();
  }

  void addTeamMember(String name, String instrumentType) {
    if (teamMembers.containsKey(instrumentType)) {
      teamMembers[instrumentType]!.add({'name': name});
      notifyListeners();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAdpDJDqocgxCgJf9lnWQXJpqiz-glksms",
      appId: "1:336372665366:android:26865213e013a987017937",
      messagingSenderId: "336372665366",
      projectId: "chenda-melam-event-scheduler",
      storageBucket: "chenda-melam-event-scheduler.appspot.com",
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppData()),
        Provider(create: (_) => AuthService()),
      ],
      child: const ChendaMelamApp(),
    ),
  );
}

class ChendaMelamApp extends StatelessWidget {
  const ChendaMelamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chenda Melam Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
        '/announcement': (context) => const AnnouncementPage(),
        '/schedule': (context) => const SchedulePage(),
        '/payment': (context) => const PaymentTrackerPage(),
        '/program-details': (context) {
          final index = ModalRoute.of(context)!.settings.arguments as int;
          return ProgramDetailsPage(programIndex: index);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}