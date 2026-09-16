import 'package:flutter/material.dart';

class DepartmentManagementScreen extends StatelessWidget {
  const DepartmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final departments = [
      ['Computer Applications', '120 Students', '10 Faculty'],
      ['Management', '100 Students', '8 Faculty'],
      ['Commerce', '90 Students', '7 Faculty'],
      ['Science', '110 Students', '9 Faculty'],
      ['Arts', '80 Students', '6 Faculty'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Department Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final department = departments[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.business),
              title: Text(department[0]),
              subtitle: Text(
                '${department[1]} • ${department[2]}',
              ),
            ),
          );
        },
      ),
    );
  }
}