import 'package:flutter/material.dart';

class ParentNotificationsScreen extends StatelessWidget {
  const ParentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      [
        'New Notice',
        'A new college notice has been published.',
        'Today',
      ],
      [
        'Assignment Update',
        'Rahul has submitted the Database assignment.',
        'Yesterday',
      ],
      [
        'Attendance Update',
        'Monthly attendance report is now available.',
        '2 days ago',
      ],
      [
        'Exam Schedule',
        'Semester examination schedule has been updated.',
        '4 days ago',
      ],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.notifications),
              ),
              title: Text(
                notification[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${notification[1]}\n${notification[2]}',
              ),
            ),
          );
        },
      ),
    );
  }
}