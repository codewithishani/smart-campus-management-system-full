import 'package:flutter/material.dart';

class StudentEventsScreen extends StatelessWidget {
  const StudentEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = [
      ['Annual Cultural Fest', '20 Sep 2026', 'College Auditorium'],
      ['Sports Day', '25 Sep 2026', 'College Ground'],
      ['Technical Symposium', '30 Sep 2026', 'Seminar Hall'],
      ['Coding Competition', '05 Oct 2026', 'Computer Lab'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Events')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.event),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event[0],
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Date: ${event[1]}'),
                        Text('Venue: ${event[2]}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
