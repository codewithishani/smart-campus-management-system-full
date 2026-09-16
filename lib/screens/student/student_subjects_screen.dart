import 'package:flutter/material.dart';

class StudentSubjectsScreen extends StatelessWidget {
  const StudentSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      ['Data Structures', 'Prof. Amit Sharma', '4 Credits', '90%'],
      ['Database Management', 'Prof. Neha Joshi', '4 Credits', '85%'],
      ['Web Development', 'Prof. Rahul Deshmukh', '3 Credits', '80%'],
      ['Software Engineering', 'Prof. Priya Kulkarni', '4 Credits', '88%'],
      ['Computer Networks', 'Prof. Sameer Patil', '3 Credits', '82%'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject[0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Faculty: ${subject[1]}'),
                  Text(subject[2]),
                  Text('Attendance: ${subject[3]}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}