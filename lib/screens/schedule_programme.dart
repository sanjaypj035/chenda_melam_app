import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import 'team_members.dart';
import 'program_details.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppData>(context, listen: false).loadScheduledPrograms();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _addProgram(AppData appData) async {
    if (_nameController.text.isEmpty) {
      _showError('Please enter program name');
      return;
    }
    if (_locationController.text.isEmpty) {
      _showError('Please enter location');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select date');
      return;
    }
    if (_selectedTime == null) {
      _showError('Please select time');
      return;
    }

    setState(() => _isLoading = true);

    final formattedDate = "${_selectedDate!.toLocal()}".split(' ')[0];
    final formattedTime = _selectedTime!.format(context);
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      _showError('User not authenticated. Please try again.');
      setState(() => _isLoading = false);
      return;
    }

    final programInfo = {
      'name': _nameController.text,
      'date': formattedDate,
      'time': formattedTime,
      'location': _locationController.text,
      'teamMembers': <String>[],
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await appData.addProgram(programInfo);

      _nameController.clear();
      _locationController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Program scheduled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Failed to save program: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _addTeamMemberToProgram(String programId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamMembersPage(programId: programId),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      try {
        final userId = _auth.currentUser?.uid;
        if (userId == null) {
          _showError('User not authenticated. Cannot add team member.');
          return null;
        }

        final memberName = result['name'];
        final memberInstrumentType = result['instrumentType'];

        await _firestore.collection('scheduledPrograms').doc(programId).update({
          'teamMembers': FieldValue.arrayUnion([
            {'name': memberName, 'instrumentType': memberInstrumentType}
          ]),
        });

        final appData = Provider.of<AppData>(context, listen: false);
        await appData.loadScheduledPrograms();
        appData.notifyListeners();

        return result;
      } catch (e) {
        _showError('Failed to add team member: ${e.toString()}');
        return null;
      }
    }

    return null;
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Schedule Program', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/image1.png',
              fit: BoxFit.scaleDown,
            ),
          ),
          Center(
            child: ConstrainedBox( // Use ConstrainedBox to set a max width
              constraints: const BoxConstraints(maxWidth: 600), // Max width of 600 pixels
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildInputFields(context),
                          const SizedBox(height: 30),
                          if (appData.scheduledPrograms.isNotEmpty) _buildScheduledProgramsList(context, appData),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields(BuildContext context) {
    return Column(
      children: [
        _buildTextField(_nameController, 'Program Name', 'Enter program name'),
        const SizedBox(height: 16),
        _buildTextField(_locationController, 'Location', 'Enter location'),
        const SizedBox(height: 20),
        _buildDatePicker(),
        const SizedBox(height: 16),
        _buildTimePicker(),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _addProgram(Provider.of<AppData>(context, listen: false)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 4,
            ),
            child: const Text(
              'Schedule Program',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.black54),
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _pickDate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              foregroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Select Date'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _selectedDate == null ? 'No date selected' : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _pickTime,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              foregroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Select Time'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _selectedTime == null ? 'No time selected' : 'Time: ${_selectedTime!.format(context)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledProgramsList(BuildContext context, AppData appData) {
    return Column(
      children: [
        const Center(
          child: Text(
            'Scheduled Programs:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appData.scheduledPrograms.length,
          itemBuilder: (context, index) {
            final program = appData.scheduledPrograms[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              color: Colors.white.withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                              Text(program['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                              const SizedBox(height: 4),
                              Text("Date: ${program['date']}", style: const TextStyle(color: Colors.black54)),
                              Text("Time: ${program['time']}", style: const TextStyle(color: Colors.black54)),
                              Text("Location: ${program['location']}", style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add, color: Colors.blue),
                          onPressed: () async {
                            final memberResult = await _addTeamMemberToProgram(program['id']);
                            if (memberResult != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Team member "${memberResult['name']}" added'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProgramDetailsPage(programIndex: index),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('See Details'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}