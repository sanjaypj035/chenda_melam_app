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
          // Content positioned within the image frame, with very tight horizontal constraints
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15, // Keep top/bottom reasonable
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: MediaQuery.of(context).size.width * 0.38, // FURTHER REDUCED left
            right: MediaQuery.of(context).size.width * 0.38, // FURTHER REDUCED right
            child: Container(
              // For debugging: uncomment to see the content bounds
              // color: Colors.red.withOpacity(0.3),
              child: ListView( // The main content ListView
                padding: const EdgeInsets.all(0), // Remove default padding
                children: membersData.entries.map((entry) {
                  final instrumentType = entry.key;
                  final members = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // Adjust margin
                    color: Colors.white.withOpacity(0.8), // Card background to match theme
                    child: Padding(
                      padding: const EdgeInsets.all(12), // Adjusted internal padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            instrumentType,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87, // Text color
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox( // Wrap Row in SizedBox to control width
                            width: MediaQuery.of(context).size.width * 0.30, // Adjusted width for TextField/Button row
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _instrumentControllers[instrumentType],
                                    style: const TextStyle(color: Colors.black87), // Text color
                                    decoration: InputDecoration(
                                      labelText: 'Add Member', // Simplified label text
                                      labelStyle: const TextStyle(color: Colors.black54, fontSize: 12), // Reduced font size
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.blue), // Blue border
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.blue), // Blue border
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.blue, width: 2.0), // Blue border
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Reduced padding
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4), // Reduced spacing
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
                                    backgroundColor: Colors.blue, // Blue background
                                    foregroundColor: Colors.white, // White text
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8), // Rounded corners
                                    ),
                                    minimumSize: Size(50, 30), // Minimum size for button
                                  ),
                                  child: const Text('Add', style: TextStyle(fontSize: 12)), // Smaller text
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Member list in this section
                          ...members.map((member) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero, // Remove ListTile's default padding
                              dense: true, // Make ListTile more compact
                              leading: Icon(Icons.person, color: Colors.blue, size: 20), // Generic person icon
                              title: Text(member['name'] ?? '', style: const TextStyle(color: Colors.black87)), // Text color
                              trailing: widget.programId != null ? null : IconButton(
                                icon: const Icon(Icons.add, color: Colors.blue, size: 20), // Icon color
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