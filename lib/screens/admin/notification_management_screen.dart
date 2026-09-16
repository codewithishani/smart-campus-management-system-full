import 'package:flutter/material.dart';

class NotificationManagementScreen extends StatelessWidget {
  const NotificationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      ['Semester Exam Schedule', 'All Students', 'Sent'],
      ['Parent-Teacher Meeting', 'All Parents', 'Sent'],
      ['Assignment Reminder', 'BCA Students', 'Sent'],
      ['Event Registration', 'All Users', 'Draft'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create notification option selected'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(item[0]),
              subtitle: Text(item[1]),
              trailing: Text(
                item[2],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item[2] == 'Sent'
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