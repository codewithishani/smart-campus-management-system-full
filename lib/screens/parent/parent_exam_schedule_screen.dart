import 'package:flutter/material.dart';

class ParentExamScheduleScreen extends StatelessWidget {
  const ParentExamScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exams = [
      ['10 Dec 2026', 'Programming', '10:00 AM'],
      ['12 Dec 2026', 'Database Management', '10:00 AM'],
      ['15 Dec 2026', 'Web Development', '10:00 AM'],
      ['17 Dec 2026', 'Computer Networks', '10:00 AM'],
      ['19 Dec 2026', 'Software Engineering', '10:00 AM'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Examination Schedule')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exams.length,
        itemBuilder: (context, index) {
          final exam = exams[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.event),
              ),
              title: Text(exam[1]),
              subtitle: Text('${exam[0]} • ${exam[2]}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }
}