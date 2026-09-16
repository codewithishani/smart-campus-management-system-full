import 'package:flutter/material.dart';

class RolePermissionsScreen extends StatelessWidget {
  const RolePermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = [
      ['Admin', 'Full system access'],
      ['Faculty', 'Attendance, marks, assignments, notices'],
      ['Student', 'Academic information and submissions'],
      ['Parent', 'Linked student information'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Role & Permissions')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: Text(
                role[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(role[1]),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Edit permissions for ${role[0]}'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}