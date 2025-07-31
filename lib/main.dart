import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/auth_service.dart';
import 'screens/auth/login.dart';
import 'screens/announcement.dart';
import 'screens/launch_screen.dart';
import 'screens/schedule_programme.dart';
// import 'screens/payment.dart'; // THIS LINE IS GONE FOR GOOD.
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

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      _hasError = false;
      notifyListeners();

      await Future.wait([
        loadAnnouncements(),
        loadScheduledPrograms(),
        loadTeamMembers(),
      ]);
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load data: ${e.toString()}';
      debugPrint('Initialization error: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnnouncements() async {
    try {
      final snapshot = await _firestore.collection('announcements')
          .orderBy('timestamp', descending: true)
          .get(const GetOptions(source: Source.serverAndCache));

      announcements = snapshot.docs.map((doc) => doc['text'] as String).toList();
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load announcements';
      debugPrint('Error loading announcements: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> addAnnouncement(String announcement) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _firestore.collection('announcements').add({
        'text': announcement,
        'timestamp': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
      });
      
      announcements.insert(0, announcement);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding announcement: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> removeAnnouncement(int index) async {
    if (index < 0 || index >= announcements.length) return;
    
    try {
      final announcementToRemove = announcements[index];
      final snapshot = await _firestore.collection('announcements')
          .where('text', isEqualTo: announcementToRemove)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        await _firestore.collection('announcements')
            .doc(snapshot.docs.first.id)
            .delete();
      }
      
      announcements.removeAt(index);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing announcement: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> loadScheduledPrograms() async {
    try {
      final snapshot = await _firestore.collection('scheduledPrograms')
          .orderBy('date', descending: false)
          .get(const GetOptions(source: Source.serverAndCache));

      scheduledPrograms = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'id': doc.id,
          'date': data['date'] ?? '',
          'time': data['time'] ?? '',
          'teamMembers': _parseTeamMembers(data['teamMembers']),
        };
      }).toList();

      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Failed to load programs';
      debugPrint('Error loading programs: ${e.toString()}');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _parseTeamMembers(dynamic membersData) {
    if (membersData == null) return [];
    if (membersData is! List) return [];

    return membersData.map((member) {
      if (member is Map<String, dynamic>) {
        return {
          'name': member['name'] ?? 'Unknown',
          'instrumentType': member['instrumentType'] ?? 'Unknown',
          'paymentStatus': member['paymentStatus'] ?? 'Pending',
          'id': member['id'] ?? (member['name'] ?? 'Unknown'),
        };
      } else if (member is String) {
        return {
          'name': member,
          'instrumentType': 'Unknown',
          'paymentStatus': 'Pending',
          'id': member,
          'legacyData': true
        };
      }
      return {'name': 'Invalid', 'instrumentType': 'Unknown', 'paymentStatus': 'Pending', 'id': 'Invalid'};
    }).toList();
  }

  Future<void> addProgram(Map<String, dynamic> program) async {
    try {
      final docRef = await _firestore.collection('scheduledPrograms').add({
        ...program,
        'createdAt': FieldValue.serverTimestamp(),
        'teamMembers': [],
      });
      
      scheduledPrograms.add({
        ...program,
        'id': docRef.id,
        'teamMembers': [],
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding program: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> loadProgramTeamMembers(String programId) async {
    try {
      final doc = await _firestore.collection('scheduledPrograms').doc(programId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final programIndex = scheduledPrograms.indexWhere((p) => p['id'] == programId);
        if (programIndex != -1) {
          scheduledPrograms[programIndex]['teamMembers'] = _parseTeamMembers(data['teamMembers']);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading program team members: ${e.toString()}');
    }
  }

  Future<void> loadTeamMembers() async {
    try {
      final snapshot = await _firestore.collection('teamMembers').get();
      
      teamMembers.forEach((key, value) => value.clear());
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final instrumentType = data['instrumentType'] as String?;
        final name = data['name'] as String?;
        
        if (instrumentType != null && name != null && teamMembers.containsKey(instrumentType)) {
          teamMembers[instrumentType]!.add({
            'name': name,
            'id': doc.id,
          });
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading team members: ${e.toString()}');
    }
  }

  Future<void> addTeamMember(String name, String instrumentType, {String? programId}) async {
    final validInstruments = ['Idamthala', 'Valamthala', 'Kombu', 'Kuzhalu', 'Ilathaalam'];
    final normalizedInstrument = validInstruments.firstWhere(
      (i) => i.toLowerCase() == instrumentType.trim().toLowerCase(),
      orElse: () => 'Unknown'
    );

    final memberData = {
      'name': name.trim(),
      'instrumentType': normalizedInstrument,
      'addedAt': Timestamp.now(),
      'paymentStatus': 'Pending',
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    if (programId != null) {
      await _firestore.collection('scheduledPrograms').doc(programId).update({
        'teamMembers': FieldValue.arrayUnion([memberData])
      });

      final programIndex = scheduledPrograms.indexWhere((p) => p['id'] == programId);
      if (programIndex != -1) {
        scheduledPrograms[programIndex]['teamMembers'] = [
          ...scheduledPrograms[programIndex]['teamMembers'] ?? [],
          memberData
        ];
      }
    } else {
      final docRef = await _firestore.collection('teamMembers').add({
        'name': name,
        'instrumentType': normalizedInstrument,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      teamMembers[normalizedInstrument]!.add({
        'name': name,
        'id': docRef.id,
      });
    }
    
    notifyListeners();
  }

  Future<void> removeTeamMember(String memberName, String instrumentType, {String? programId}) async {
    try {
      if (programId != null) {
        await _removeProgramTeamMember(programId, memberName, instrumentType);
      } else {
        await _removeGeneralTeamMember(memberName, instrumentType);
      }
    } catch (e) {
      debugPrint('Error removing team member: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _removeGeneralTeamMember(String memberName, String instrumentType) async {
    final query = await _firestore.collection('teamMembers')
        .where('name', isEqualTo: memberName)
        .where('instrumentType', isEqualTo: instrumentType)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await _firestore.collection('teamMembers').doc(query.docs.first.id).delete();
    }

    teamMembers[instrumentType]!.removeWhere((member) => member['name'] == memberName);
    notifyListeners();
  }

  Future<void> _removeProgramTeamMember(String programId, String memberName, String instrumentType) async {
    DocumentSnapshot programDoc = await _firestore.collection('scheduledPrograms').doc(programId).get();

    if (!programDoc.exists) {
      debugPrint('Program document does not exist for removal.');
      return;
    }

    List<dynamic> currentTeamMembers = List.from(programDoc.get('teamMembers') ?? []);
    Map<String, dynamic>? memberToRemoveFromFirestore;

    for (var member in currentTeamMembers) {
      if (member is Map<String, dynamic> &&
          member['name'] == memberName &&
          member['instrumentType'] == instrumentType) {
        memberToRemoveFromFirestore = member;
        break;
      }
    }

    if (memberToRemoveFromFirestore == null) {
      debugPrint('Team member not found in program for removal: ${memberName} (${instrumentType})');
      return;
    }

    await _firestore.collection('scheduledPrograms').doc(programId).update({
      'teamMembers': FieldValue.arrayRemove([memberToRemoveFromFirestore])
    });

    final programIndex = scheduledPrograms.indexWhere((p) => p['id'] == programId);
    if (programIndex != -1) {
      final updatedProgram = Map<String, dynamic>.from(scheduledPrograms[programIndex]);
      updatedProgram['teamMembers'] = List<Map<String, dynamic>>.from(
        updatedProgram['teamMembers'] ?? []
      )..removeWhere((m) => m['name'] == memberName && m['instrumentType'] == instrumentType);
      
      scheduledPrograms[programIndex] = updatedProgram;
      notifyListeners();
    }
  }

  Future<void> updateTeamMemberPaymentStatus(
      String programId, String memberName, String instrumentType, String newStatus) async {
    try {
      DocumentSnapshot programDoc = await _firestore.collection('scheduledPrograms').doc(programId).get();

      if (!programDoc.exists) {
        debugPrint('Program document does not exist for status update.');
        return;
      }

      List<dynamic> currentTeamMembers = List.from(programDoc.get('teamMembers') ?? []);

      Map<String, dynamic>? memberToUpdate;
      
      List<Map<String, dynamic>> membersToRemove = [];
      List<Map<String, dynamic>> membersToAdd = [];


      for (var member in currentTeamMembers) {
        if (member is Map<String, dynamic> &&
            member['name'] == memberName &&
            member['instrumentType'] == instrumentType) {
          memberToUpdate = Map<String, dynamic>.from(member);
          membersToRemove.add(memberToUpdate); 
          
          memberToUpdate['paymentStatus'] = newStatus;
          membersToAdd.add(memberToUpdate);
          break;
        }
      }

      if (memberToUpdate == null) {
        debugPrint('Team member not found in program for status update: ${memberName} (${instrumentType})');
        return;
      }

      if (membersToRemove.isNotEmpty) {
        await _firestore.collection('scheduledPrograms').doc(programId).update({
          'teamMembers': FieldValue.arrayRemove(membersToRemove),
        });
        await _firestore.collection('scheduledPrograms').doc(programId).update({
          'teamMembers': FieldValue.arrayUnion(membersToAdd),
        });
      }
      
      final localProgramIndex = scheduledPrograms.indexWhere((p) => p['id'] == programId);
      if (localProgramIndex != -1) {
        List<Map<String, dynamic>> localMembers = List<Map<String, dynamic>>.from(scheduledPrograms[localProgramIndex]['teamMembers'] ?? []);
        
        localMembers.removeWhere((m) => m['name'] == memberName && m['instrumentType'] == instrumentType);
        localMembers.add(memberToUpdate);
        
        scheduledPrograms[localProgramIndex] = {...scheduledPrograms[localProgramIndex], 'teamMembers': localMembers};
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating team member payment status: ${e.toString()}');
      rethrow;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAdpDJDqocgxCgJf9lnWQXJpqiz-glksms",
        appId: "1:336372665366:android:26865213e013a987017937",
        messagingSenderId: "336372665366",
        projectId: "chenda-melam-event-scheduler",
        storageBucket: "chenda-melam-event-scheduler.appspot.com",
      ),
    );

    try {
      await FirebaseFirestore.instance.enablePersistence(
        PersistenceSettings(
          synchronizeTabs: true,
        ),
      );
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('Firestore persistence configuration failed: ${e.toString()}');
    }

    final appData = AppData();
    final initializationSuccess = await _initializeAppData(appData);

    if (!initializationSuccess) {
      await Future.delayed(const Duration(seconds: 2));
      await _initializeAppData(appData);
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => appData),
          Provider(create: (_) => AuthService()),
        ],
        child: const ChendaMelamApp(),
      ),
    );
  } catch (e) {
    debugPrint('Fatal initialization error: ${e.toString()}');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to initialize app'),
                Text('Error: ${e.toString()}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> _initializeAppData(AppData appData) async {
  try {
    await appData.initialize();
    return true;
  } catch (e) {
    debugPrint('AppData initialization failed: ${e.toString()}');
    return false;
  }
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
      home: const LaunchScreen(),
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/announcement': (context) => const AnnouncementPage(),
        '/schedule': (context) => const SchedulePage(),
        // '/payment': (context) => const PaymentTrackerPage(), // This line needs to be fully deleted
        '/program-details': (context) {
          final index = ModalRoute.of(context)!.settings.arguments as int;
          return ProgramDetailsPage(programIndex: index);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
