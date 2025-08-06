import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class TeamMembersPage extends StatefulWidget {
  final String? programId;

  const TeamMembersPage({super.key, this.programId});

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
  void initState() {
    super.initState();
    if (widget.programId != null) {
      Provider.of<AppData>(context, listen: false)
          .loadProgramTeamMembers(widget.programId!);
    }
  }

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

  Future<void> _addMember(String name, String instrumentType) async {
    try {
      final appData = Provider.of<AppData>(context, listen: false);
      await appData.addTeamMember(
        name,
        instrumentType,
        programId: widget.programId,
      );

      _instrumentControllers[instrumentType]!.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      _showError('Failed to add member: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final membersData = widget.programId != null 
        ? _getProgramMembers(appData) 
        : appData.teamMembers;

    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      appBar: AppBar(
        title: Text(widget.programId != null ? "Program Team" : "Team Members", style: const TextStyle(color: Colors.white)), // Text color
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Icon color
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true, // Extend body behind transparent app bar
      body: Stack(
        children: [
          // Background Image
          Center(
            child: Image.asset(
              'assets/images/image1.png', // Use image1.png as background
              fit: BoxFit.scaleDown, // Ensure no zooming
            ),
          ),
          Center( // Center the content
            child: ConstrainedBox( // Constrain the width for readability
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView( // The main content
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Column(
                  children: membersData.entries.map((entry) {
                    final instrumentType = entry.key;
                    final members = entry.value;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white.withOpacity(0.8),
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
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _instrumentControllers[instrumentType],
                                    style: const TextStyle(color: Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'Add Member',
                                      labelStyle: const TextStyle(color: Colors.black54, fontSize: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.blue),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.blue),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                ElevatedButton(
                                  onPressed: () {
                                    final name = _instrumentControllers[instrumentType]!.text.trim();
                                    if (name.isEmpty) {
                                      _showError('Please enter a name');
                                      return;
                                    }

                                    final nameExists = members.any((member) => 
                                      (member['name'] ?? '').toLowerCase() == name.toLowerCase());
                                    
                                    if (nameExists) {
                                      _showError('"$name" is already added');
                                    } else {
                                      _addMember(name, instrumentType);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    minimumSize: const Size(50, 30),
                                  ),
                                  child: const Text('Add', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...members.map((member) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                leading: const Icon(Icons.person, color: Colors.blue, size: 20),
                                title: Text(member['name'] ?? '', style: const TextStyle(color: Colors.black87)),
                                trailing: widget.programId != null ? null : IconButton(
                                  icon: const Icon(Icons.add, color: Colors.blue, size: 20),
                                  onPressed: () {
                                    Navigator.pop(context, {
                                      'name': member['name'] ?? '',
                                      'instrumentType': instrumentType
                                    });
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _getProgramMembers(AppData appData) {
    if (widget.programId == null) return {};
    
    final program = appData.scheduledPrograms.firstWhere(
      (p) => p['id'] == widget.programId,
      orElse: () => {},
    );
    
    if (program.isEmpty) return {};
    
    final programMembers = program['teamMembers'] as List<dynamic>? ?? [];
    final result = <String, List<Map<String, dynamic>>>{};
    
    for (var member in programMembers) {
      if (member is Map<String, dynamic>) {
        final instrument = (member['instrumentType'] as String?)?.trim() ?? 'Unknown';
        final name = member['name'] as String? ?? 'Unknown';
        
        if (!result.containsKey(instrument)) {
          result[instrument] = [];
        }
        
        result[instrument]!.add({
          'name': name,
          'instrumentType': instrument
        });
      }
    }
    
    return result;
  }
}