import 'package:flutter/material.dart';

class ParentNoticesScreen extends StatelessWidget {
  const ParentNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = [
      [
        'Parent-Teacher Meeting',
        'Parent-teacher meeting will be conducted on Saturday.',
        '05 Sep 2026',
      ],
      [
        'Semester Examination',
        'Semester examination schedule has been published.',
        '03 Sep 2026',
      ],
      [
        'College Event',
        'Annual cultural event will be conducted this month.',
        '01 Sep 2026',
      ],
      [
        'Attendance Notice',
        'Parents are requested to monitor student attendance.',
        '29 Aug 2026',
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
            child: ListTile(
              leading: const Icon(Icons.campaign),
              title: Text(
                notice[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${notice[1]}\n${notice[2]}'),
              ),
            ),
          );
        },
      ),
    );
  }
}