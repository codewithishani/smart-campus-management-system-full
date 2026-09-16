import 'package:flutter/material.dart';

class ParentAssignmentStatusScreen extends StatelessWidget {
  const ParentAssignmentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignments = [
      ['Flutter UI Design', 'Submitted', 'Programming'],
      ['Database ER Model', 'Submitted', 'DBMS'],
      ['Portfolio Website', 'Pending', 'Web Development'],
      ['Network Report', 'Submitted', 'Computer Networks'],
      ['Software Project', 'Pending', 'Software Engineering'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Status')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final item = assignments[index];
          final submitted = item[1] == 'Submitted';

          return Card(
            child: ListTile(
              leading: Icon(
                submitted
                    ? Icons.check_circle
                    : Icons.pending_actions,
                color: submitted ? Colors.green : Colors.orange,
              ),
              title: Text(item[0]),
              subtitle: Text(item[2]),
              trailing: Text(
                item[1],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: submitted ? Colors.green : Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}