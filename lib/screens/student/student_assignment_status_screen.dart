import 'package:flutter/material.dart';

class StudentAssignmentStatusScreen extends StatelessWidget {
  const StudentAssignmentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignments = [
      ['Data Structures', 'Pending', '15 Sep 2026'],
      ['Database Management', 'Submitted', '18 Sep 2026'],
      ['Web Development', 'Checked', '20 Sep 2026'],
      ['Software Engineering', 'Submitted', '22 Sep 2026'],
      ['Computer Networks', 'Pending', '25 Sep 2026'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Status')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final item = assignments[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.assignment),
              ),
              title: Text(
                item[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Due: ${item[2]}'),
              trailing: Text(
                item[1],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item[1] == 'Pending'
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}