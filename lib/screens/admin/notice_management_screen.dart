import 'package:flutter/material.dart';

class NoticeManagementScreen extends StatelessWidget {
  const NoticeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = [
      ['Parent-Teacher Meeting', 'Published', '05 Sep 2026'],
      ['Semester Examination', 'Published', '03 Sep 2026'],
      ['Annual Cultural Event', 'Published', '01 Sep 2026'],
      ['Attendance Reminder', 'Draft', '29 Aug 2026'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notice Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create notice option selected')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.campaign),
              title: Text(notice[0]),
              subtitle: Text(notice[2]),
              trailing: Text(
                notice[1],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: notice[1] == 'Published'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}