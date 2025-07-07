import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class PaymentTrackerPage extends StatefulWidget {
  const PaymentTrackerPage({super.key});

  @override
  State<PaymentTrackerPage> createState() => _PaymentTrackerPageState();
}

class _PaymentTrackerPageState extends State<PaymentTrackerPage> {
  final TextEditingController programController = TextEditingController();
  final TextEditingController memberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<Map<String, String>> payments = [];

  void _addPayment() {
    if (programController.text.isNotEmpty &&
        memberController.text.isNotEmpty &&
        amountController.text.isNotEmpty) {
      setState(() {
        payments.add({
          'program': programController.text,
          'member': memberController.text,
          'amount': amountController.text,
        });
        programController.clear();
        memberController.clear();
        amountController.clear();
      });
    }
  }

  void _removePayment(int index) {
    setState(() {
      payments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: programController,
              decoration: const InputDecoration(labelText: "Program Name"),
            ),
            TextField(
              controller: memberController,
              decoration: const InputDecoration(labelText: "Member Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount (INR)"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPayment,
              child: const Text("Add Payment"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: payments.isEmpty
                  ? const Center(child: Text("No payments recorded yet."))
                  : ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              "${payment['member']} - ₹${payment['amount']}",
                            ),
                            subtitle: Text("Program: ${payment['program']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removePayment(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}