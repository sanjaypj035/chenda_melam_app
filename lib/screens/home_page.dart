import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _secureStorage.delete(key: 'email');
      await _secureStorage.delete(key: 'password');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }

  String _getEventStatus(Map<String, dynamic> program) {
    final now = DateTime.now();
    final eventDate = DateTime.parse(program['date']);
    final eventTimeParts = program['time'].split(':');
    final eventHour = int.parse(eventTimeParts[0]);
    final eventMinute = int.parse(eventTimeParts[1].split(' ')[0]);
    final isPM = program['time'].contains('PM');

    final actualEventHour = isPM && eventHour != 12 ? eventHour + 12 : (isPM && eventHour == 12 ? 12 : eventHour);
    
    final eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      actualEventHour,
      eventMinute,
    );

    return eventDateTime.isBefore(now) ? 'Completed' : 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final upcomingPrograms = appData.scheduledPrograms;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.blue[800]),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/ecstacy-of-thrissur-pooram-PT2T39.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[100]!,
                    Colors.blue[50]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Organize performances, team members, and schedules',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  if (upcomingPrograms.isNotEmpty) ...[
                    Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: upcomingPrograms.length,
                      itemBuilder: (context, index) {
                        final program = upcomingPrograms[index];
                        final status = _getEventStatus(program);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      program['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == 'Completed'
                                            ? Colors.green[100]
                                            : Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: status == 'Completed'
                                              ? Colors.green[800]
                                              : Colors.orange[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: ${program['date']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Time: ${program['time']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Location: ${program['location']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Text(
                      'No upcoming events scheduled',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildFeatureButton(
                    context,
                    'Announcements',
                    Icons.campaign,
                    '/announcement',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureButton(
                    context,
                    'Schedule Program',
                    Icons.event,
                    '/schedule',
                  ),
                  // REMOVED: Payment Tracker button
                  // const SizedBox(height: 16),
                  // _buildFeatureButton(
                  //   context,
                  //   'Payment Tracker',
                  //   Icons.payments,
                  //   '/payment',
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
      BuildContext context, String text, IconData icon, String route) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}