import 'package:flutter/material.dart';

class FacultyClassSubjectsScreen extends StatelessWidget {
  const FacultyClassSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = [
      ['BCA - Semester 5', 'Data Structures', '45 Students'],
      ['BCA - Semester 5', 'Database Management', '42 Students'],
      ['BCA - Semester 3', 'Programming Fundamentals', '38 Students'],
      ['BCA - Semester 6', 'Software Engineering', '40 Students'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Class & Subjects')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final item = classes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.school),
              ),
              title: Text(
                item[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${item[1]}\n${item[2]}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}