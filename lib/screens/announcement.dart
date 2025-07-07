import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final TextEditingController announcementController = TextEditingController();

    void _addAnnouncement() {
      if (announcementController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter announcement text'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      appData.addAnnouncement(announcementController.text.trim());
      announcementController.clear();
    }

    void _removeAnnouncement(int index) {
      appData.removeAnnouncement(index);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: announcementController,
                  decoration: const InputDecoration(
                    labelText: 'New Announcement',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your announcement here...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addAnnouncement,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Post Announcement'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: appData.announcements.isEmpty
                ? const Center(
                    child: Text(
                      'No announcements yet',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: appData.announcements.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key('$index-${appData.announcements[index]}'),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) => _removeAnnouncement(index),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              appData.announcements[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAnnouncement(index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}