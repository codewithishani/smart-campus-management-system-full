import 'package:flutter/material.dart';

class FacultyLeaveRequestsScreen extends StatelessWidget {
  const FacultyLeaveRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      ['LR001', 'Rahul Patil', 'Medical Leave', 'Pending'],
      ['LR002', 'Sneha Joshi', 'Personal Leave', 'Approved'],
      ['LR003', 'Aditya Kulkarni', 'Family Function', 'Pending'],
      ['LR004', 'Priya Deshmukh', 'Medical Leave', 'Rejected'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.event_busy),
              ),
              title: Text(
                request[1],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${request[0]} • ${request[2]}',
              ),
              trailing: Text(
                request[3],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: request[3] == 'Approved'
                      ? Colors.green
                      : request[3] == 'Rejected'
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Leave request details are in demo mode.',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}