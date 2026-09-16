import 'package:flutter/material.dart';

class ParentLeaveInformationScreen extends StatelessWidget {
  const ParentLeaveInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaves = [
      ['02 Sep 2026', '02 Sep 2026', 'Medical Leave', 'Approved'],
      ['18 Aug 2026', '19 Aug 2026', 'Personal Leave', 'Approved'],
      ['10 Jul 2026', '10 Jul 2026', 'Family Function', 'Pending'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Information')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          final leave = leaves[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(leave[2]),
              subtitle: Text(
                '${leave[0]} to ${leave[1]}',
              ),
              trailing: Text(
                leave[3],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: leave[3] == 'Approved'
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