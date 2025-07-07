import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class ProgramDetailsPage extends StatelessWidget {
  final int programIndex;

  const ProgramDetailsPage({super.key, required this.programIndex});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final program = appData.scheduledPrograms[programIndex];
    final teamMembers = (program['teamMembers'] as List<dynamic>).cast<String>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Program Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(),
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(program['name'] ?? ''),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(program['location'] ?? ''),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(program['date'] ?? ''),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(program['time'] ?? ''),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Team Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (teamMembers.isEmpty)
              const Text('No team members assigned yet.')
            else
              Column(
                children: appData.teamMembers.entries.map((entry) {
                  final instrumentType = entry.key;
                  final members = entry.value
                      .where((member) => teamMembers.contains(member['name']))
                      .toList();

                  if (members.isEmpty) return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instrumentType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...members.map((member) => ListTile(
                            title: Text(member['name'] ?? ''),
                          )).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}