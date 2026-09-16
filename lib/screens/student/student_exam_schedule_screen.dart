import 'package:flutter/material.dart';

class StudentExamScheduleScreen extends StatelessWidget {
  const StudentExamScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exams = [
      ['Data Structures', '10 Oct 2026', '10:00 AM - 12:00 PM'],
      ['Database Management', '12 Oct 2026', '10:00 AM - 12:00 PM'],
      ['Web Development', '14 Oct 2026', '10:00 AM - 12:00 PM'],
      ['Software Engineering', '16 Oct 2026', '10:00 AM - 12:00 PM'],
      ['Computer Networks', '18 Oct 2026', '10:00 AM - 12:00 PM'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Schedule')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.event),
              ),
              title: Text(
                exam[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${exam[1]}\n${exam[2]}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}