import 'package:flutter/material.dart';

class StudentNoticesScreen extends StatelessWidget {
  const StudentNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = [
      [
        'Semester Examination Notice',
        'Semester examinations will begin from 10 October 2026.',
        '05 Sep 2026',
      ],
      [
        'Assignment Submission Notice',
        'Students must submit pending assignments before the due date.',
        '03 Sep 2026',
      ],
      [
        'College Event Notice',
        'Annual cultural event registration is now open.',
        '01 Sep 2026',
      ],
      [
        'Attendance Notice',
        'Students should maintain the minimum attendance requirement.',
        '30 Aug 2026',
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notices')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.notifications),
              ),
              title: Text(
                notice[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${notice[1]}\n${notice[2]}'),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}