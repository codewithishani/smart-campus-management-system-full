import 'package:flutter/material.dart';

class FacultyStudentListScreen extends StatelessWidget {
  const FacultyStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      ['S001', 'Rahul Patil', 'BCA - Sem 5', '85%'],
      ['S002', 'Sneha Joshi', 'BCA - Sem 5', '92%'],
      ['S003', 'Aditya Kulkarni', 'BCA - Sem 5', '78%'],
      ['S004', 'Priya Deshmukh', 'BCA - Sem 5', '88%'],
      ['S005', 'Rohan Shinde', 'BCA - Sem 5', '81%'],
      ['S006', 'Neha Patil', 'BCA - Sem 5', '90%'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Student List')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(student[0].substring(1)),
              ),
              title: Text(
                student[1],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${student[0]} • ${student[2]}',
              ),
              trailing: Text(
                student[3],
                style: const TextStyle(
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