import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;
  String? _tempAnnouncementText;

  late Stream<QuerySnapshot> _announcementsStream;

  @override
  void initState() {
    super.initState();
    _announcementsStream = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _addAnnouncement(String text) async {
    try {
      await FirebaseFirestore.instance.collection('announcements').add({
        'text': text,
        'timestamp': Timestamp.now(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement posted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post announcement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/image1.png',
              fit: BoxFit.scaleDown,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.22,
            right: MediaQuery.of(context).size.width * 0.22,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 290.0,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isEditing
                          ? TextField(
                              controller: _controller,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: 'Type your announcement...',
                                hintStyle: TextStyle(color: Colors.white70),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              autofocus: true,
                              cursorColor: Colors.blue,
                            )
                          : Text(
                              _tempAnnouncementText ?? 'Tap "Post Announcement" to create one.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 290.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () async {
                          if (_isEditing) {
                            if (_controller.text.isNotEmpty) {
                              await _addAnnouncement(_controller.text);
                              _controller.clear();
                              _tempAnnouncementText = null;
                            }
                          }
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        child: Text(
                          _isEditing ? 'Submit Announcement' : 'Post Announcement',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (!_isEditing)
                      const Text(
                        'Recent Announcements',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (!_isEditing)
                      const SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _announcementsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(color: Colors.blue);
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text(
                              'No announcements yet.',
                              style: TextStyle(color: Colors.white54, fontSize: 16),
                              textAlign: TextAlign.center,
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                              Timestamp timestamp = data['timestamp'] as Timestamp;
                              DateTime dateTime = timestamp.toDate();
                              String formattedDate =
                                  '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

                              return Align(
                                alignment: Alignment.center,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 290.0,
                                  ),
                                  child: Card(
                                    color: Colors.grey[850],
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['text'],
                                            style: const TextStyle(color: Colors.white, fontSize: 15),
                                          ),
                                          const SizedBox(height: 5),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              formattedDate,
                                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
