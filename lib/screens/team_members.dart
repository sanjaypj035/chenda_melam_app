import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({super.key});

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  final Map<String, TextEditingController> _instrumentControllers = {
    'Idamthala': TextEditingController(),
    'Valamthala': TextEditingController(),
    'Kombu': TextEditingController(),
    'Kuzhalu': TextEditingController(),
    'Ilathaalam': TextEditingController(),
  };

  @override
  void dispose() {
    _instrumentControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Members"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: appData.teamMembers.entries.map((entry) {
          final instrumentType = entry.key;
          final members = entry.value;

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instrumentType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _instrumentControllers[instrumentType],
                          decoration: InputDecoration(
                            labelText: 'Add $instrumentType Member',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = _instrumentControllers[instrumentType]!.text.trim();
                          if (name.isEmpty) return;

                          final nameExists = members.any((member) => 
                            (member['name'] ?? '').toLowerCase() == name.toLowerCase());
                          
                          if (nameExists) {
                            _showError('"$name" is already added');
                          } else {
                            appData.addTeamMember(name, instrumentType);
                            _instrumentControllers[instrumentType]!.clear();
                            FocusScope.of(context).unfocus();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...members.map((member) {
                    return ListTile(
                      title: Text(member['name'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.pop(context, member['name'] ?? '');
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}