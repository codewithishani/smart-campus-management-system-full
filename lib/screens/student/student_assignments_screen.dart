import 'package:flutter/material.dart';

class StudentAssignmentsScreen extends StatelessWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignments = [
      ['Data Structures', 'Binary Tree Implementation', '15 Sep 2026', 'Pending'],
      ['Database', 'SQL Database Project', '18 Sep 2026', 'Submitted'],
      ['Web Development', 'Responsive Website', '20 Sep 2026', 'Pending'],
      ['Software Engineering', 'Agile Case Study', '22 Sep 2026', 'Submitted'],
      ['Networks', 'Network Design Report', '25 Sep 2026', 'Pending'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final a = assignments[index];
          final submitted = a[3] == 'Submitted';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a[0],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(a[1]),
                  const SizedBox(height: 8),
                  Text('Due Date: ${a[2]}'),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(a[3]),
                    avatar: Icon(
                      submitted ? Icons.check : Icons.pending,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}