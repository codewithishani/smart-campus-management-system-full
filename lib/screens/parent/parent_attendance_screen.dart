import 'package:flutter/material.dart';

class ParentAttendanceScreen extends StatelessWidget {
  const ParentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      ['Programming', '88%'],
      ['Database Management', '84%'],
      ['Web Development', '90%'],
      ['Computer Networks', '82%'],
      ['Software Engineering', '81%'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Monitoring')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Overall Attendance',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '85%',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Subject-wise Attendance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...subjects.map(
            (subject) => Card(
              child: ListTile(
                leading: const Icon(Icons.fact_check),
                title: Text(subject[0]),
                trailing: Text(
                  subject[1],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}