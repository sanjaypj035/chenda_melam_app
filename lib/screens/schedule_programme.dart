import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'team_members.dart';
import 'program_details.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  void _addProgram(AppData appData) {
    if (nameController.text.isEmpty) {
      _showError('Please enter program name');
      return;
    }
    if (locationController.text.isEmpty) {
      _showError('Please enter location');
      return;
    }
    if (selectedDate == null) {
      _showError('Please select date');
      return;
    }
    if (selectedTime == null) {
      _showError('Please select time');
      return;
    }

    final formattedDate = "${selectedDate!.toLocal()}".split(' ')[0];
    final formattedTime = selectedTime!.format(context);
    final programInfo = {
      'name': nameController.text,
      'date': formattedDate,
      'time': formattedTime,
      'location': locationController.text,
      'teamMembers': <String>[],
    };

    appData.addProgram(programInfo);

    nameController.clear();
    locationController.clear();
    setState(() {
      selectedDate = null;
      selectedTime = null;
    });
  }

  Future<String?> _addTeamMemberToProgram() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TeamMembersPage(),
      ),
    );
    return result;
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
      appBar: AppBar(title: const Text('Schedule Program')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Program Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'No date selected'
                        : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text('Select Time'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? 'No time selected'
                        : 'Time: ${selectedTime!.format(context)}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _addProgram(appData),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Schedule Program'),
            ),
            const SizedBox(height: 20),
            if (appData.scheduledPrograms.isNotEmpty) ...[
              const Text(
                'Scheduled Programs:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...appData.scheduledPrograms.asMap().entries.map((entry) {
                final index = entry.key;
                final program = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    program['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("Date: ${program['date']}"),
                                  Text("Time: ${program['time']}"),
                                  Text("Location: ${program['location']}"),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () async {
                                final member = await _addTeamMemberToProgram();
                                if (member != null) {
                                  setState(() {
                                    appData.scheduledPrograms[index]['teamMembers']
                                        .add(member);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Team member "$member" added'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgramDetailsPage(programIndex: index),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text('See Details'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}