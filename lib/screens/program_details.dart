import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'team_members.dart';

class ProgramDetailsPage extends StatefulWidget {
  final int programIndex;

  const ProgramDetailsPage({super.key, required this.programIndex});

  @override
  State<ProgramDetailsPage> createState() => _ProgramDetailsPageState();
}

class _ProgramDetailsPageState extends State<ProgramDetailsPage> {
  @override
  void initState() {
    super.initState();
    _loadProgramData();
  }

  Future<void> _loadProgramData() async {
    final program = Provider.of<AppData>(context, listen: false)
        .scheduledPrograms[widget.programIndex];
    await Provider.of<AppData>(context, listen: false)
        .loadProgramTeamMembers(program['id']);
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final program = appData.scheduledPrograms[widget.programIndex];
    final teamMembers = program['teamMembers'] as List<dynamic>? ?? [];

    const List<String> validInstruments = [
      'Idamthala',
      'Valamthala',
      'Kombu',
      'Kuzhalu',
      'Ilathaalam',
    ];

    final membersByInstrument = <String, List<Map<String, dynamic>>>{};
    for (var instrument in validInstruments) {
      membersByInstrument[instrument] = [];
    }
    membersByInstrument['Unknown'] = [];


    for (var member in teamMembers) {
      if (member is! Map<String, dynamic>) continue;

      final rawInstrument = (member['instrumentType'] as String?)?.trim();
      final memberName = (member['name'] as String?)?.trim() ?? 'Unknown';
      final paymentStatus = (member['paymentStatus'] as String?)?.trim() ?? 'Pending';
      final memberId = member['id'] as String? ?? memberName; 

      String foundInstrument = 'Unknown';
      for (var instrument in validInstruments) {
        if (instrument.toLowerCase() == rawInstrument?.toLowerCase()) {
          foundInstrument = instrument;
          break;
        }
      }
      
      membersByInstrument[foundInstrument]!.add({
        'name': memberName,
        'instrumentType': foundInstrument,
        'paymentStatus': paymentStatus,
        'id': memberId,
      });
    }

    final sortedInstruments = membersByInstrument.keys.toList()
      ..sort((a, b) => a == 'Unknown'
          ? 1
          : b == 'Unknown'
            ? -1
            : a.compareTo(b));

    if (membersByInstrument['Unknown']!.isEmpty) {
      sortedInstruments.remove('Unknown');
    }


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(program['name'] ?? 'Program Details', style: const TextStyle(color: Colors.white)),
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
              'assets/images/image1.png', // Background image for Program Details page
              fit: BoxFit.scaleDown, // No zooming
            ),
          ),
          Center( // Use Center to position content
            child: ConstrainedBox( // Constrain the width for better readability
              constraints: const BoxConstraints(maxWidth: 400),
              child: RefreshIndicator(
                onRefresh: () => _loadProgramData(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 2,
                        color: Colors.white.withOpacity(0.8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Program Details',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                              ),
                              const Divider(),
                              _buildDetailRow('Date', program['date'] ?? 'Not specified'),
                              _buildDetailRow('Time', program['time'] ?? 'Not specified'),
                              _buildDetailRow('Location', program['location'] ?? 'Not specified'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team Members',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                          ),
                          const Divider(),
                          if (membersByInstrument.values.every((list) => list.isEmpty))
                            const Center(child: Text('No team members added yet', style: TextStyle(color: Colors.black54)))
                          else
                            Card(
                              elevation: 2,
                              color: Colors.white.withOpacity(0.8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey.shade300),
                                  columnWidths: const {
                                    0: FlexColumnWidth(1.0),
                                    1: FlexColumnWidth(2.0),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(color: Colors.grey.shade200),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Instrument',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Members',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                    for (final instrument in sortedInstruments)
                                      if (membersByInstrument[instrument]?.isNotEmpty ?? false)
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text(instrument, style: const TextStyle(color: Colors.black87)),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  for (final member in membersByInstrument[instrument]!)
                                                    InkWell(
                                                      onTap: () => _showPaymentStatusDialog(
                                                        program['id'],
                                                        member['name'],
                                                        instrument,
                                                        member['paymentStatus'] as String,
                                                        member['id'] as String,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                member['name'],
                                                                style: TextStyle(
                                                                  color: _getInstrumentColor(instrument),
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                            ),
                                                            _getPaymentStatusIcon(member['paymentStatus'] as String),
                                                            const SizedBox(width: 8),
                                                            IconButton(
                                                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                                              onPressed: () => _removeTeamMember(
                                                                context,
                                                                program['id'],
                                                                member['name'],
                                                                instrument,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                  ],
                                ),
                              ),
                            ),
                        ],
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

  Widget _getPaymentStatusIcon(String status) {
    IconData icon;
    Color color;
    String tooltip;

    switch (status.toLowerCase()) {
      case 'paid':
        icon = Icons.check_circle;
        color = Colors.green;
        tooltip = 'Payment Paid';
        break;
      case 'advance':
        icon = Icons.account_balance_wallet;
        color = Colors.orange;
        tooltip = 'Advance Paid';
        break;
      case 'pending':
      default:
        icon = Icons.info;
        color = Colors.red;
        tooltip = 'Payment Pending';
        break;
    }
    return Tooltip(
      message: tooltip,
      child: Icon(icon, color: color, size: 20),
    );
  }

  Color _getInstrumentColor(String instrumentType) {
    switch (instrumentType.toLowerCase()) {
      case 'idamthala':
        return Colors.red.shade700;
      case 'valamthala':
        return Colors.blue.shade700;
      case 'kombu':
        return Colors.green.shade700;
      case 'kuzhalu':
        return Colors.orange.shade700;
      case 'ilathaalam':
        return Colors.purple.shade700;
      default:
        return Colors.grey;
    }
  }

  Widget _getInstrumentIcon(String instrumentType) {
    return const SizedBox(width: 0, height: 0);
  }

  void _navigateToTeamMembers(BuildContext context, String programId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamMembersPage(programId: programId),
      ),
    ).then((_) => _loadProgramData());
  }

  Future<void> _removeTeamMember(
    BuildContext context,
    String programId,
    String name,
    String instrumentType,
  ) async {
    try {
      await Provider.of<AppData>(context, listen: false)
          .removeTeamMember(name, instrumentType, programId: programId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name removed from team'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove member: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showPaymentStatusDialog(
      String programId, String memberName, String instrumentType, String currentStatus, String memberId) async {
    String? selectedStatus = currentStatus;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text('Update Payment for $memberName'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Paid'),
                    value: 'Paid',
                    groupValue: selectedStatus,
                    onChanged: (String? value) {
                      setStateInDialog(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Advance'),
                    value: 'Advance',
                    groupValue: selectedStatus,
                    onChanged: (String? value) {
                      setStateInDialog(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Pending'),
                    value: 'Pending',
                    groupValue: selectedStatus,
                    onChanged: (String? value) {
                      setStateInDialog(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStatus != null && selectedStatus != currentStatus) {
                      try {
                        await Provider.of<AppData>(context, listen: false)
                            .updateTeamMemberPaymentStatus(
                                programId, memberName, instrumentType, selectedStatus!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment status updated for $memberName to $selectedStatus'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context, selectedStatus);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update status: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pop(context, null);
                      }
                    } else {
                      Navigator.pop(context, null);
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
      }
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}