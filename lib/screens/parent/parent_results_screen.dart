import 'package:flutter/material.dart';

class ParentResultsScreen extends StatelessWidget {
  const ParentResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      ['Programming', '86', 'A'],
      ['Database Management', '82', 'A'],
      ['Web Development', '88', 'A+'],
      ['Computer Networks', '79', 'B+'],
      ['Software Engineering', '84', 'A'],
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Results & Marks')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: const [
                  Text('Current CGPA'),
                  SizedBox(height: 8),
                  Text(
                    '8.2',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Semester 5'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Subject Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...results.map(
            (result) => Card(
              child: ListTile(
                title: Text(result[0]),
                subtitle: Text('Marks: ${result[1]} / 100'),
                trailing: Text(
                  result[2],
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