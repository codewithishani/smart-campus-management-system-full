import 'package:flutter/material.dart';

class EventManagementScreen extends StatelessWidget {
  const EventManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      ['Annual Cultural Event', '15 Sep 2026', 'Main Auditorium'],
      ['Sports Day', '20 Sep 2026', 'College Ground'],
      ['Technical Fest', '05 Oct 2026', 'Computer Lab'],
      ['Parent-Teacher Meeting', '10 Oct 2026', 'Seminar Hall'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Event Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create event option selected')),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.event),
              ),
              title: Text(event[0]),
              subtitle: Text(
                '${event[1]}\n${event[2]}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}