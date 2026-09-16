import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      ['S001', 'Rahul Patil', 'Student', 'Active'],
      ['F001', 'Prof. Amit Sharma', 'Faculty', 'Active'],
      ['P001', 'Rajesh Patil', 'Parent', 'Active'],
      ['S002', 'Priya Sharma', 'Student', 'Active'],
      ['F002', 'Prof. Neha Joshi', 'Faculty', 'Active'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: Text(user[1]),
              subtitle: Text(
                '${user[0]} • ${user[2]}',
              ),
              trailing: Text(
                user[3],
                style: const TextStyle(
                  color: Colors.green,
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