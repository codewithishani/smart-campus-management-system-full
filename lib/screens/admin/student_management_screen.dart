import 'package:flutter/material.dart';

class StudentManagementScreen extends StatelessWidget {
  const StudentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      ['S001', 'Rahul Patil', 'BCA', 'Semester 5'],
      ['S002', 'Priya Sharma', 'BCA', 'Semester 5'],
      ['S003', 'Amit Joshi', 'BCA', 'Semester 5'],
      ['S004', 'Sneha More', 'BBA', 'Semester 3'],
      ['S005', 'Rohan Desai', 'BCA', 'Semester 5'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Student Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add student option selected')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(student[1]),
              subtitle: Text(
                '${student[0]} • ${student[2]} • ${student[3]}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}