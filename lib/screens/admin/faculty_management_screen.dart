import 'package:flutter/material.dart';

class FacultyManagementScreen extends StatelessWidget {
  const FacultyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faculty = [
      ['F001', 'Prof. Amit Sharma', 'Computer Applications'],
      ['F002', 'Prof. Neha Joshi', 'Computer Applications'],
      ['F003', 'Prof. Rahul Deshmukh', 'Computer Applications'],
      ['F004', 'Prof. Sneha Kulkarni', 'Management'],
      ['F005', 'Prof. Anil Patil', 'Commerce'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add faculty option selected')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faculty.length,
        itemBuilder: (context, index) {
          final person = faculty[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(person[1]),
              subtitle: Text(
                '${person[0]} • ${person[2]}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}