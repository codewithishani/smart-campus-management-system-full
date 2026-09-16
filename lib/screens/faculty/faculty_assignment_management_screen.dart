import 'package:flutter/material.dart';

class FacultyAssignmentManagementScreen extends StatelessWidget {
  const FacultyAssignmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignments = [
      ['Binary Tree Implementation', 'Data Structures', '15 Sep 2026', '45'],
      ['SQL Database Project', 'Database Management', '18 Sep 2026', '42'],
      ['Agile Case Study', 'Software Engineering', '22 Sep 2026', '40'],
      ['Network Design Report', 'Computer Networks', '25 Sep 2026', '38'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Management'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Create Assignment is in demo mode.',
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.assignment),
              ),
              title: Text(
                assignment[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${assignment[1]}\nDue: ${assignment[2]}\nStudents: ${assignment[3]}',
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Assignment details opened in demo mode.',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}