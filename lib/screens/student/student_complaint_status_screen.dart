import 'package:flutter/material.dart';

class StudentComplaintStatusScreen extends StatelessWidget {
  const StudentComplaintStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = [
      ['C001', 'Classroom Projector Issue', 'Resolved'],
      ['C002', 'Wi-Fi Connectivity Issue', 'In Progress'],
      ['C003', 'Library Timing Request', 'Submitted'],
      ['C004', 'Lab Computer Issue', 'Resolved'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Status')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final complaint = complaints[index];

          Color statusColor;

          if (complaint[2] == 'Resolved') {
            statusColor = Colors.green;
          } else if (complaint[2] == 'In Progress') {
            statusColor = Colors.orange;
          } else {
            statusColor = Colors.blue;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.support_agent),
              ),
              title: Text(
                complaint[1],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Complaint ID: ${complaint[0]}'),
              trailing: Text(
                complaint[2],
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}