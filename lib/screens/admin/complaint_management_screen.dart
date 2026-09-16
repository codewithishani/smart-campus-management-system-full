import 'package:flutter/material.dart';

class ComplaintManagementScreen extends StatelessWidget {
  const ComplaintManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = [
      ['C001', 'S001', 'Classroom Projector', 'Resolved'],
      ['C002', 'S002', 'Library Computer', 'Pending'],
      ['C003', 'S003', 'Wi-Fi Connectivity', 'In Progress'],
      ['C004', 'S004', 'Classroom Fan', 'Resolved'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.report_problem),
              title: Text(complaint[2]),
              subtitle: Text(
                'Complaint: ${complaint[0]}\nStudent: ${complaint[1]}',
              ),
              isThreeLine: true,
              trailing: Text(
                complaint[3],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: complaint[3] == 'Resolved'
                      ? Colors.green
                      : complaint[3] == 'Pending'
                          ? Colors.orange
                          : Colors.blue,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}